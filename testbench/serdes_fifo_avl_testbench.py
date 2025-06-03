import avl
import avl.templates
import cocotb
import copy
from cocotb.triggers import RisingEdge
import random
from z3 import  Implies


class serdes_item(avl.Sequence_Item):
    def __init__(self, name, parent_sequence):
        super().__init__(name, parent_sequence)

        # Inputs : Randomised 
        # set parallel in to 0 if not valid to make waves more readable
        self.parallel_in     = avl.Uint8("parallel_in", 0, fmt=str)
        self.valid_in = avl.Logic("valid_in", 0, fmt=str, width=1, signed=False)
        # This circuit can only take an average of one packet every 8 cycles.
        # The fifo enables the ability to buffer the input. 
        # Here we are constraining the random value of valid to occour just above 1 in 8 cycles therefore will eventually fill up the fifo and drop packets.
        # Increasing the FIFO depth would increase the amount of time before packets are dropped. 
        # This would allow for bursty traffic 
        self.add_constraint("c_valid",lambda x: x == int(random.random()<0.126), self.valid_in)
        #self.add_constraint("c_valid_gate", lambda x,y: Implies(x== 0, y==0), self.valid_in, self.parallel_in)

        # Outputs : for observation/prediction
        self.parallel_out    = avl.Uint8("parallel_out", 0, fmt=str,auto_random=False)
        self.ready_out  = avl.Logic("ready_out", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.valid_out  = avl.Logic("valid_out", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.full  = avl.Logic("fifo_full", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.empty  = avl.Logic("fifo_empty", 0, fmt=str,auto_random=False, width=1, signed=False)

    def randomize(self):
        super().randomize()

# Driver is simple, takes randomised inputs from sequencer and writes to the DUT
class serdes_driver(avl.templates.Vanilla_Driver):
    async def reset(self):
        self.hdl.parallel_in.value = 0
        self.hdl.valid_in.value = 0

    async def run_phase(self):
        await self.reset()

        await RisingEdge(self.hdl.clk)
        while True:
            item = await self.seq_item_port.blocking_get()

            while True:
                await RisingEdge(self.hdl.clk)
                if self.rst.value == 0:
                    await self.reset()
                else:
                    break

            self.hdl.valid_in.value = item.valid_in.value
            self.hdl.parallel_in.value = item.parallel_in.value if item.valid_in.value == 1 else 0 
            item.set_event("done")

# Monitor also simply reads the dut and exports the trasaction on each clock edge
class serdes_monitor(avl.templates.Vanilla_Monitor):
    def __init__(self, name, parent):
        super().__init__(name, parent)

        self.cg = avl.Covergroup('cg',self)
        self.cp = self.cg.add_coverpoint('full', lambda: self.hdl.fifo_full.value)
        self.cp.add_bin('full',1)
        self.cp.add_bin('not_full',0)
        self.cp = self.cg.add_coverpoint('empty', lambda: self.hdl.fifo_empty.value)
        self.cp.add_bin('empty',1)
        self.cp.add_bin('not_empty',0)

    async def run_phase(self):
        while True:
            await RisingEdge(self.clk)
            
            if self.rst.value == 0:
                continue

            item = serdes_item("item", None)
            item.parallel_in.value = int(self.hdl.parallel_in.value)
            item.valid_in.value = int(self.hdl.valid_in.value)
            item.parallel_out.value = int(self.hdl.parallel_out.value)
            item.ready_out.value = int(self.hdl.ready_out.value)
            item.valid_out.value = int(self.hdl.valid_out.value)
            item.full.value = int(self.hdl.fifo_full.value)
            item.empty.value = int(self.hdl.fifo_empty.value)
 
            self.item_export.write(item)

            self.cg.sample()

    async def report_phase(self):
        cocotb.log.warning(self.cg.report(full=True))

class serdes_model(avl.templates.Vanilla_Model):
    def __init__(self, name, parent):
       super().__init__(name, parent)
       self.fifo = avl.Fifo(18)

    async def fifo_full(self):
        if len(self.fifo) == self.fifo.depth:
            return True
        else:
            return False

    async def fifo_empty(self):
        if len(self.fifo) == 0:
            return True
        else:
            return False


    async def run_phase(self):
        while True:
            # for the sake of keeping this testbench simple and not implementing the details of the interals of the serdes
            # I make the assumption that the write side of the fifo is covered by other testbenches and works.
            # This allows me to use the flags to keep track of the fifo contents and what order data should be coming out. 
            # this requires oversizing the model fifo as this will contain more data than the DUT 
            # some checks should be done on latency but overall we are interested in data in = data out and exact latency is not important. 

            monitor_item = await self.item_port.blocking_get()
            model_item = copy.deepcopy(monitor_item)
            # clear outputs to ensure no false positives and all outputs are models 
            model_item.parallel_out.value = None
            model_item.full.value = None
            model_item.empty.value = None
            model_item.ready_out.value = None
            model_item.valid_out.value = None

            full = monitor_item.full.value

            if monitor_item.valid_out.value:
                data_out = await self.fifo.blocking_pop()
            else :
                data_out = 0 
                    
            if model_item.valid_in.value and not full:
                self.fifo.append(model_item.parallel_in.value)

            #update outputs 
            model_item.parallel_out.value = data_out

            # This testbench does not cover the following signals
            model_item.valid_out.value =  monitor_item.valid_out.value
            model_item.full.value = monitor_item.full.value 
            model_item.empty.value = monitor_item.empty.value
            model_item.ready_out.value = monitor_item.ready_out.value

            self.item_export.write(model_item)

# this sets up common signals such as clock and reset and 
# instantates N-agents (as determied by factory settings)
class serdes_env(avl.templates.Vanilla_Env):
    def __init__(self, name, parent):
        super().__init__(name, parent)
  
@cocotb.test()
async def test(dut):
    # Create the environment
    # the hdl variable connect the dut to all of the avl_objects. each avl_object has a hdl variable, 
    # for example this allows the avl_monitor to be able to read the dut IO  
    avl.Factory.set_variable('*.hdl', dut)
    avl.Factory.set_variable('*.clk', dut.clk)
    avl.Factory.set_variable('*.rst', dut.rst_n)
    avl.Factory.set_variable('env.cfg.timeout_ns', 10)
    avl.Factory.set_variable('*.n_items', 3000)

    avl.Factory.set_variable('serdes_env.agent*.has_model', True)
    avl.Factory.set_variable('serdes_env.agent*.has_scoreboard', True)

    # vanilla.py references classes which may be overridden therefore when for example you
    # want to make some override to the monitor class, you do not need to re-write the agent class
    # to include this modified monitor. 
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Driver, serdes_driver)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Monitor, serdes_monitor)
    avl.Factory.set_override_by_type(avl.Sequence_Item, serdes_item)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Model, serdes_model)
    # the agent and scoreboard are both using the Vanilla classes

    e = serdes_env('serdes_env', None)

    avl.Visualization.diagram(e)

    await e.start()     
