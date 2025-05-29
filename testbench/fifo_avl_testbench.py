# Copyright 2024 Apheleia
#
# Description:
# Apheleia phase example

import avl
import avl.templates
import cocotb
from cocotb.triggers import RisingEdge

import copy

class fifo_item(avl.Sequence_Item):
    def __init__(self, name, parent_sequence):
        super().__init__(name, parent_sequence)

        # Inputs : Randomised 
        self.data_in     = avl.Uint8("data_in", 0, fmt=str)
        self.write_valid = avl.Logic("write_valid", 0, fmt=str, width=1, signed=False)
        self.read_ready  = avl.Logic("read_ready", 0, fmt=str, width=1, signed=False)

        # Outputs : for observation/prediction
        self.data_out    = avl.Uint8("data_out", 0, fmt=str,auto_random=False)
        self.write_ready  = avl.Logic("write_ready", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.read_valid  = avl.Logic("read_valid", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.full  = avl.Logic("full", 0, fmt=str,auto_random=False, width=1, signed=False)
        self.empty  = avl.Logic("empty", 0, fmt=str,auto_random=False, width=1, signed=False)

    def randomize(self):
        super().randomize()

# Driver is simple, takes randomised inputs from sequencer and writes to the DUT
class fifo_driver(avl.templates.Vanilla_Driver):
    async def reset(self):
        self.hdl.data_in.value = 0
        self.hdl.write_valid.value = 0
        self.hdl.read_ready.value = 0

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

            self.hdl.write_valid.value = item.write_valid.value
            self.hdl.data_in.value = item.data_in.value
            self.hdl.read_ready.value = item.read_ready.value
            item.set_event("done")

# Monitor also simply reads the dut and exports the trasaction on each clock edge
class fifo_monitor(avl.templates.Vanilla_Monitor):
    def __init__(self, name, parent):
        super().__init__(name, parent)

        self.cg = avl.Covergroup('cg',self)
        self.cp = self.cg.add_coverpoint('full', lambda: self.hdl.full.value)
        self.cp.add_bin('full',1)
        self.cp.add_bin('not_full',0)
        self.cp = self.cg.add_coverpoint('empty', lambda: self.hdl.empty.value)
        self.cp.add_bin('empty',1)
        self.cp.add_bin('not_empty',0)

    async def run_phase(self):
        while True:
            await RisingEdge(self.clk)
            
            if self.rst.value == 0:
                continue

            item = fifo_item("item", None)
            item.data_in.value = int(self.hdl.data_in.value)
            item.write_valid.value = int(self.hdl.write_valid.value)
            item.read_ready.value = int(self.hdl.read_ready.value)
            item.data_out.value = int(self.hdl.data_out.value)
            item.write_ready.value = int(self.hdl.write_ready.value)
            item.read_valid.value = int(self.hdl.read_valid.value)
            item.full.value = int(self.hdl.full.value)
            item.empty.value = int(self.hdl.empty.value)
 
            self.item_export.write(item)

            self.cg.sample()

    async def report_phase(self):
        print(self.cg.report(full=True))

class fifo_model(avl.templates.Vanilla_Model):
    def __init__(self, name, parent):
       super().__init__(name, parent)
       self.fifo = avl.Fifo(16)

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
        data_out = 0
        data_out_next = 0
        read_valid_next = 0 
        full = 0 
        empty = 0 
        write_ready = 0 
        read_valid = 0 
        while True:
            # Items read through ports are mutable. This means that the object written to the model export must be unique from the incoming port.
            # this can be through copying the item, this is dangerous as it is also copying the outputs from the hdl
            # which if missed could lead to a false positve 
            # alternativly (as below) the inputs could be manually copied and then outputs handled by the model.

            monitor_item = await self.item_port.blocking_get()
            model_item = copy.deepcopy(monitor_item)
            # clear outputs to ensure no false positives and all outputs are models 
            model_item.data_out.value = None
            model_item.full.value = None
            model_item.empty.value = None
            model_item.write_ready.value = None
            model_item.read_valid.value = None

            #single cycle latnecy for data read
            read_valid = read_valid_next
            # valid data only on output for single cycle
            data_out = data_out_next if read_valid_next else 0

            # evaluate full and empty before modifying fifo contents 
            full = 1 if await self.fifo_full() else 0
            empty = 1 if await self.fifo_empty() else 0 

            write_ready = 0 if full else 1
            read_valid_next = 0 #default value

            if not empty:
                if model_item.read_ready.value:
                    data_out_next = await self.fifo.blocking_pop()
                    read_valid_next = 1 
            else: 
                data_out_next = 0 
                    
            if model_item.write_valid.value and not full:
                self.fifo.append(model_item.data_in.value)

            #update outputs 
            model_item.data_out.value = data_out
            model_item.full.value = full
            model_item.empty.value = empty
            model_item.write_ready.value = write_ready
            model_item.read_valid.value = read_valid 

            self.item_export.write(model_item)

# this sets up common signals such as clock and reset and 
# instantates N-agents (as determied by factory settings)
class fifo_env(avl.templates.Vanilla_Env):
    def __init__(self, name, parent):
        super().__init__(name, parent)
  
@cocotb.test
async def test(dut):
    # Create the environment
    # the hdl variable connect the dut to all of the avl_objects. each avl_object has a hdl variable, 
    # for example this allows the avl_monitor to be able to read the dut IO  
    avl.Factory.set_variable('*.hdl', dut)
    avl.Factory.set_variable('*.clk', dut.clk)
    avl.Factory.set_variable('*.rst', dut.rst_n)
    avl.Factory.set_variable('env.cfg.timeout_ns', 10)
    avl.Factory.set_variable('*.n_items', 2000)

    avl.Factory.set_variable('fifo_env.agent*.has_model', True)
    avl.Factory.set_variable('fifo_env.agent*.has_scoreboard', True)

    # vanilla.py references classes which may be overridden therefore when for example you
    # want to make some override to the monitor class, you do not need to re-write the agent class
    # to include this modified monitor. 
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Driver, fifo_driver)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Monitor, fifo_monitor)
    avl.Factory.set_override_by_type(avl.Sequence_Item, fifo_item)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Model, fifo_model)
    # the agent and scoreboard are both using the Vanilla classes

    e = fifo_env('fifo_env', None)

    avl.Visualization.diagram(e)

    await e.start()     