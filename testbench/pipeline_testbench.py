import cocotb
import random
import math
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer
from collections import deque


@cocotb.test
async def pipeline_test(dut):
    #generate clock
    cocotb.start_soon(Clock(dut.clk_i,1,units="ns").start())

    dut.rst_n_i.value = 1

    dut.valid_i.value = 0
    dut.ready_i.value = 0

    # reset dut
    dut.rst_n_i.value = 0
    # hold reset for 3 clock

    for _ in range(3):
        await RisingEdge(dut.clk_i)

    dut.rst_n_i.value = 1

    expected = deque()

    cocotb.start_soon(write_process(dut,expected))
    cocotb.start_soon(read_process(dut,expected))

    await Timer(100,units='ns')
    print(expected)


async def write_process(dut,expected):
    count = 1
    while True:
        await RisingEdge(dut.clk_i)
        write = int(random.random()*2)
        write = 1
        if dut.ready_o.value:
            if write == 1:
                dut.valid_i.value = 1
                dut.data_i.value = count
                expected.append(count)
                count = (count + 1)%(2**8)
            else: 
                dut.valid_i.value = 0

async def read_process(dut,expected):
    read_req = 0 
    while True:
        await RisingEdge(dut.clk_i)

        if dut.valid_o.value and read_req:
            read_req = 0
            read_data = dut.data_o.value
            expected_data = expected.popleft()
            print(f"expected data: {int(expected_data)} read data: {int(read_data)}")

            assert read_data == expected_data
    
        if (not read_req):
            #await Timer(0.1, units='ns')
            dut.ready_i.value = 0
            read_req = int(random.random()*2)
            if read_req == 1:
                dut.ready_i.value = 1