import avl 
import avl.templates 
import cocotb
import copy
from cocotb.triggers import RisingEdge

from functools import reduce 
import operator as op 
import numpy as np

from hamming_funcs import * 


class hamming_encode_item(avl.Sequence_Item):
    def __init__(self, name, parent_sequence):
        super().__init__(name, parent_sequence)

        self.data_width = avl.Factory.get_variable(f"{self.get_full_name()}.data_width", None)

        # Inputs : Randomised 
        self.data_in_i     = avl.Logic("data_in_i", 0, fmt=str, width=self.data_width)

        # Outputs : for observation/prediction
        coded_data_width = self.data_width + hamming_address_width(self.data_width) + 1; 
        #coded_data_width = 39; 
        self.data_out_o    = avl.Logic("data_out_o", 0, fmt=str, width=coded_data_width, auto_random=False)

    def randomize(self):
        super().randomize()

# Driver is simple, takes randomised inputs from sequencer and writes to the DUT
class hamming_encode_driver(avl.templates.Vanilla_Driver):
    async def reset(self):
        self.hdl.data_in_i.value = 0

    async def run_phase(self):
        await self.reset()

        await RisingEdge(self.hdl.clk_i)
        while True:
            item = await self.seq_item_port.blocking_get()

            while True:
                await RisingEdge(self.hdl.clk_i)
                if self.rst.value == 0:
                    await self.reset()
                else:
                    break

            self.hdl.data_in_i.value = item.data_in_i.value
            item.set_event("done")

# Monitor also simply reads the dut and exports the trasaction on each clock edge
class hamming_encode_monitor(avl.templates.Vanilla_Monitor):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    async def run_phase(self):
        while True:
            await RisingEdge(self.clk)
            
            if self.rst.value == 0:
                await RisingEdge(self.clk)
                await RisingEdge(self.clk)
                continue

            item = hamming_encode_item("item", None)
            item.data_in_i.value = int(self.hdl.data_in_i.value)
            item.data_out_o.value = int(self.hdl.data_out_o.value)
 
            self.item_export.write(item)

class hamming_encode_model(avl.templates.Vanilla_Model):
    def __init__(self, name, parent):
       super().__init__(name, parent)


    async def run_phase(self):
        data_out = 0
        while True:
            # Items read through ports are mutable. This means that the object written to the model export must be unique from the incoming port.
            # this can be through copying the item, this is dangerous as it is also copying the outputs from the hdl
            # which if missed could lead to a false positve 
            # alternativly (as below) the inputs could be manually copied and then outputs handled by the model.

            monitor_item = await self.item_port.blocking_get()
            model_item = copy.deepcopy(monitor_item)
            # clear outputs to ensure no false positives and all outputs are models 
            model_item.data_out_o.value = None

            data_width = model_item.data_in_i.width
            bit_array  = np.array(list(np.binary_repr(model_item.data_in_i.value, width=model_item.data_in_i.width))).astype(int)
            bit_array = bit_array[::-1]

            k = data_width
            r=0
            while (2 ** r) < (k + r + 1):
                r += 1

            bit_array = np.insert(bit_array,0,0)
            for i in range(r):
                bit_array = np.insert(bit_array,2**i,0)

            parity_bit_array = bin(reduce(op.xor,[i for i, bit in enumerate(bit_array) if bit]))

            for i, parity_bit in enumerate(parity_bit_array[:1:-1]):
                bit_array[2**i] = parity_bit

            bit_array[0] = reduce(op.xor,[bit for bit in bit_array])
            result = bit_array.dot(1 << np.arange(bit_array.shape[-1]))

            #update outputs 
            model_item.data_out_o.value = result

            self.item_export.write(model_item)

# this sets up common signals such as clock and reset and 
# instantates N-agents (as determied by factory settings)
class hamming_encode_env(avl.templates.Vanilla_Env):
    def __init__(self, name, parent):
        super().__init__(name, parent)
  
@cocotb.test()
async def test(dut):
    # Create the environment
    # the hdl variable connect the dut to all of the avl_objects. each avl_object has a hdl variable, 
    # for example this allows the avl_monitor to be able to read the dut IO  
    avl.Factory.set_variable('*.hdl', dut)
    avl.Factory.set_variable('*.clk', dut.clk_i)
    avl.Factory.set_variable('*.rst', dut.rst_n_i)
    avl.Factory.set_variable('env.cfg.timeout_ns', 10)
    avl.Factory.set_variable('*.n_items', 2000)

    avl.Factory.set_variable('*item.data_width', 32)

    avl.Factory.set_variable('hamming_encode_env.agent*.has_model', True)
    avl.Factory.set_variable('hamming_encode_env.agent*.has_scoreboard', True)

    # vanilla.py references classes which may be overridden therefore when for example you
    # want to make some override to the monitor class, you do not need to re-write the agent class
    # to include this modified monitor. 
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Driver, hamming_encode_driver)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Monitor, hamming_encode_monitor)
    avl.Factory.set_override_by_type(avl.Sequence_Item, hamming_encode_item)
    avl.Factory.set_override_by_type(avl.templates.Vanilla_Model, hamming_encode_model)
    # the agent and scoreboard are both using the Vanilla classes

    e = hamming_encode_env('hamming_encode_env', None)

    avl.Visualization.diagram(e)

    await e.start()     
