import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from functools import reduce 
import operator as op 
import numpy as np

@cocotb.test
async def hamming_test(dut):


    #set bits constrain to data width 
    #insert blank space at 2^^i
    #calcualte xor reduction 
    #insert bits 
    #calculate extended parity 
    #np.random.seed(1023930)

    data_width = 32
    bits = np.random.randint(0,2,data_width)

    input = int(bits.dot(1 << np.arange(bits.shape[-1])))


    k = data_width
    r=0
    while (2 ** r) < (k + r + 1):
        r += 1

    bits = np.insert(bits,0,0)
    for i in range(r):
        bits = np.insert(bits,2**i,0)


    parity_bits = bin(reduce(op.xor,[i for i, bit in enumerate(bits) if bit]))

    for i, parity_bit in enumerate(parity_bits[:1:-1]):
        bits[2**i] = parity_bit

    bits[0] = reduce(op.xor,[bit for bit in bits])
    result = bits.dot(1 << np.arange(bits.shape[-1]))

    #generate clock 
    cocotb.start_soon(Clock(dut.clk_i,1,units="ns").start()) 

    dut.rst_n_i.value = 1
    dut.data_in_i.value = 0

    # reset dut
    dut.rst_n_i.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk_i)
    
    dut.rst_n_i.value = 1
    dut.data_in_i.value = input
    
    for count in range(10):
        await RisingEdge(dut.clk_i)
    
    
    print(dut.data_out_o.value.binstr)
    print("".join([str(i) for i in np.flip(bits)]))
    print(dut.data_out_o.value.integer)
    print(result)

    assert dut.data_out_o.value.integer == result, \
    "Error, expected %s, got %s" % (dut.data_out_o.value.integer,result)
  
    parity_bits = bin(reduce(op.xor,[i for i, bit in enumerate(bits) if bit]))
    print(parity_bits)
    bits[9] = 0 if bits[9] else 1 
    parity_bits = bin(reduce(op.xor,[i for i, bit in enumerate(bits) if bit]))
    print(parity_bits)
