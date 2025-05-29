import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random

@cocotb.test
async def basic_count_test(dut):
    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1
    dut.parallel_in.value = 123
    dut.valid_in.value = 0


    # reset dut
    dut.rst_n.value = 0
    # hold reset for 2 clock 

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1
    
    for count in range(50):
        dut.valid_in.value = 0 
        if (dut.ready_out.value):
            dut.valid_in.value = 1
        await RisingEdge(dut.clk)
  
    