import cocotb 
import random
import math 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


@cocotb.test
async def g2b_test(dut):

    cocotb.start_soon(Clock(dut.clk_i,1,units="ns").start()) 

    dut.rst_n_i.value = 1

    # reset dut
    dut.rst_n_i.value = 0
    # hold reset for 2 clock 

    for _ in range(2):
        await RisingEdge(dut.clk_i)
    
    dut.rst_n_i.value = 1

    for i in range(100):
        input = int(random.random()*15)
        print(input)
        expected_bin = g2b_func(input) 

        dut.gray_code_i.value = input

        for _ in range(5):
            await RisingEdge(dut.clk_i)
    
        result = dut.binary_o.value

        print("expected %s, result %s"%(bin(expected_bin),bin(result)))
        assert expected_bin == result

    
def g2b_func(graycode): 
    if graycode == 0:
        return graycode
    len = int(math.log2(graycode))+1
    print(f"len {len}")
    result = graycode >> (len - 1)
    print(f"result {result}")
    for i in range(len-1):
        isolated_bit = (graycode >> (len - 2 - i))%2
        print("isolated bit %s"%isolated_bit)
        result_bit = result%2 ^ isolated_bit
        print(result_bit)
        result = result << 1
        result = result + result_bit  
    return result 
