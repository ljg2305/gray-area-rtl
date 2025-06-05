import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test
async def hamming_test(dut):
    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1
    dut.data_in.value = 0

    # reset dut
    dut.rst_n.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1
    dut.data_in.value = 22927655 
    
    for count in range(10):
        await RisingEdge(dut.clk)
    
    print(dut.data_out.value.binstr)
  