import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random

@cocotb.test
async def pulse_test(dut):
    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1
    dut.hold.value = 0 
    dut.signal_in.value = 0

    # reset dut
    dut.rst_n.value = 0
    # hold reset for 2 clock 

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1
    
    for count in range(10):
        await RisingEdge(dut.clk)
  
    dut.signal_in.value = 1
    pulse_count = 0 
    for count in range(10):
        if (dut.pulse_out.value == 1):
            pulse_count += 1
        await RisingEdge(dut.clk)

    dut.signal_in.value = 0 

    for count in range(10):
        if (dut.pulse_out.value == 1):
            pulse_count += 1
        await RisingEdge(dut.clk)
    
    assert  pulse_count == 1, \
        "Error, pulse should have been a single cycle but lasted %s"%(pulse_count)

    # test 2 
    # TODO add assertion
    dut.signal_in.value = 1
    dut.hold.value = 1
    pulse_count = 0 
    for count in range(10):
        await RisingEdge(dut.clk)

    dut.signal_in.value = 0 
    for count in range(10):
        await RisingEdge(dut.clk)

    dut.hold.value = 0
    for count in range(10):
        await RisingEdge(dut.clk)

  
    # test 3
    # TODO add assertion
    dut.signal_in.value = 1
    dut.hold.value = 1
    for count in range(10):
        await RisingEdge(dut.clk)

    dut.hold.value = 0
    for count in range(10):
        await RisingEdge(dut.clk)

    dut.signal_in.value = 0
    for count in range(10):
        await RisingEdge(dut.clk)

    
    # test 4
    # TODO add assertion
    dut.signal_in.value = 1
    dut.hold.value = 1
    for count in range(2):
        await RisingEdge(dut.clk)

    dut.hold.value = 0
    for count in range(2):
        await RisingEdge(dut.clk)

    dut.hold.value = 1
    for count in range(2):
        await RisingEdge(dut.clk)

    dut.signal_in.value = 0

    for count in range(10):
        await RisingEdge(dut.clk)