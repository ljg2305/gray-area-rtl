import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random

@cocotb.test
async def basic_count_test(dut):
    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1
    dut.serial_in.value = 0
    dut.enable.value = 1


    # reset dut
    dut.rst_n.value = 0
    # hold reset for 2 clock 

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1

    for count in range(50):
        dut.start.value = 0 
        if count%8 ==1:
            dut.start.value = 1
            dut.serial_in.value = 0 if dut.serial_in.value else 1
        await RisingEdge(dut.clk)
    
    for count in range(50):
        await RisingEdge(dut.clk)
    dut.enable.value = 0
    previous_serial_in = dut.serial_in.value
    for count in range(800):
        dut.start.value = 0 
        dut.enable.value = random.randint(0, 1)

        if (dut.valid.value):
            expected_value = (2**8 - 1) * previous_serial_in
            assert dut.parallel_out.value == expected_value, \
                "error expected %s got %s" % (expected_value,dut.parallel_out.value)

        if count%20 ==1:
            dut.start.value = 1
            dut.serial_in.value = 0 if dut.serial_in.value else 1


        previous_serial_in = dut.serial_in.value
        await RisingEdge(dut.clk)


    