import cocotb 
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


@cocotb.test
async def b2g_test(dut):
    
    for i in range(100):
        input = int(random.random()*15)
        expected_gc = input ^ (input >> 1)
        dut.binary_i.value = input
        await Timer(10, units='ns')
        result = dut.gray_code_o.value
        await Timer(10, units='ns')
        print("expected %s, result %s"%(bin(expected_gc),bin(result)))
        assert expected_gc == result

    