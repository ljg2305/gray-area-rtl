import cocotb
import random
import math
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer
from collections import deque


@cocotb.test
async def async_fifo_test(dut):
    #generate clock
    cocotb.start_soon(Clock(dut.wr_clk_i,1,units="ns").start())
    cocotb.start_soon(Clock(dut.rd_clk_i,1.5,units="ns").start())

    dut.wr_rst_n_i.value = 1
    dut.rd_rst_n_i.value = 1

    dut.wr_enable_i.value = 0
    # reset dut
    dut.wr_rst_n_i.value = 0
    dut.rd_rst_n_i.value = 0
    # hold reset for 3 clock

    for _ in range(3):
        await RisingEdge(dut.wr_clk_i)

    dut.wr_rst_n_i.value = 1
    dut.rd_rst_n_i.value = 1

    expected = deque()

    cocotb.start_soon(write_process(dut,expected))
    cocotb.start_soon(read_process(dut,expected))

    await Timer(1000,units='ns')
    print(expected)


async def write_process(dut,expected):
    count = 1
    while True:
        await RisingEdge(dut.wr_clk_i)
        await Timer(0.1, units='ns')
        dut.wr_enable_i.value = 0
        write = int(random.random()*2)
        if write == 1 and not dut.full.value:
            dut.wr_enable_i.value = 1
            dut.wr_data_i.value = count
            expected.append(count)
            count = (count + 1)%(2**8)

async def read_process(dut,expected):
    while True:
        await RisingEdge(dut.rd_clk_i)
        await Timer(0.1, units='ns')
        dut.rd_enable_i.value = 0
        read = int(random.random()*2)
        if read == 1 and not dut.empty.value:
            dut.rd_enable_i.value = 1
            read_data = dut.rd_data_o.value
            expected_data = expected.popleft()
            assert read_data == expected_data
            print(f"expected data: {int(expected_data)} read data: {int(read_data)}")