import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge


@cocotb.test
async def basic_count_test(dut):
    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1


    # reset dut
    dut.rst_n.value = 0
    # hold reset for 2 clock 

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1

    dut.read_ready.value = 0
    dut.write_valid.value = 1
    write_values = []
    for count in range(50):
        dut.data_in.value = count + 1
        write_values.append((count+1))
        await RisingEdge(dut.clk)
    
    dut.read_ready.value = 1
    dut.write_valid.value = 0
    read_pointer = 0 

    for count in range(50):
        await RisingEdge(dut.clk)
        data_out = dut.data_out.value
        if dut.read_valid.value:
            assert data_out == write_values[read_pointer], \
            "Error, expected %s, got %s" % (write_values[read_pointer],data_out)
            read_pointer += 1

    dut.read_ready.value = 1
    dut.write_valid.value = 1
    write_values = []
    read_pointer = 0 

    for count in range(50):
        dut.data_in.value = count + 10
        write_values.append(count+10)
        await RisingEdge(dut.clk)
        data_out = dut.data_out.value

        if dut.read_valid.value:
            assert data_out == write_values[read_pointer], \
                "Error, expected %s, got %s" % (write_values[read_pointer],data_out)
            read_pointer += 1
   
    # drain fifo for next test
    dut.read_ready.value = 1
    dut.write_valid.value = 0
    for count in range(50):
        await RisingEdge(dut.clk)



    dut.read_ready.value = 0
    dut.write_valid.value = 1
    write_values = []
    read_pointer = 0 

    for count in range(50):
        dut.data_in.value = count + 20
        write_values.append(count+20)
        await RisingEdge(dut.clk)
        data_out = dut.data_out.value

        if (count == 5):
            dut.read_ready.value = 1

        if dut.read_valid.value:
            assert data_out == write_values[read_pointer], \
                "Error, expected %s, got %s" % (write_values[read_pointer],data_out)
            read_pointer += 1



    