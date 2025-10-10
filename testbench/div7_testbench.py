import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer


@cocotb.test
async def div7_test(dut):
    #generate clock
    cocotb.start_soon(Clock(dut.clk_i,1,units="ns").start())

    dut.rst_n_i.value = 1

    # reset dut
    dut.rst_n_i.value = 0
    # hold reset for 3 clock
    for _ in range(3):
        await RisingEdge(dut.clk_i)

    dut.rst_n_i.value = 1

    await Timer(100,units='ns')