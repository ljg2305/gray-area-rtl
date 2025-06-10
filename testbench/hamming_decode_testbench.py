import cocotb 
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from functools import reduce 
import operator as op 
import numpy as np

@cocotb.test
async def hamming_test(dut):

    data_width = 32
    bits = np.random.randint(0,2,data_width)

    result_bits = bits.copy()
    result = int(bits.dot(1 << np.arange(bits.shape[-1])))


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

    bits[9] = 0 if bits[9] else 1 
    input = bits.dot(1 << np.arange(bits.shape[-1]))

    #generate clock 
    cocotb.start_soon(Clock(dut.clk,1,units="ns").start()) 

    dut.rst_n.value = 1
    dut.data_in_i.value = 0

    # reset dut
    dut.rst_n.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)
    
    dut.rst_n.value = 1
    dut.data_in_i.value = int(input)
    
    for count in range(10):
        await RisingEdge(dut.clk)
    
    
    print(dut.data_out_o.value.binstr)
    print("".join([str(i) for i in np.flip(result_bits)]))
    print(dut.data_out_o.value.integer)
    print(result)

    assert dut.data_out_o.value.integer == result, \
    "Error, expected %s, got %s" % (dut.data_out_o.value.integer,result)
  
    parity_bits = bin(reduce(op.xor,[i for i, bit in enumerate(bits) if bit]))
    print(parity_bits)
    bits[9] = 0 if bits[9] else 1 
    parity_bits = bin(reduce(op.xor,[i for i, bit in enumerate(bits) if bit]))
    print(parity_bits)
