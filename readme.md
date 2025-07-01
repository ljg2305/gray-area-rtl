# Gray Area RTL Repo 

This repo is a bit of a gray area as its sole purpose is for learning and documenting myself Lawrence **Gray** re-familirsing myself with writing ASIC quality RTL. This repo will not contain all projects related to this mission but anything that sits outside this repo will be linked below.

## Getting Started

### Requirements 
#### Software: 
[Verilator](https://www.veripool.org/verilator/) \
[GTKWave](https://gtkwave.sourceforge.net/) \
[Graphviz](https://graphviz.org/download/) 

#### Python Packages: 
`avl-core`
`cocotb`
`cocotb-test`
`pytest`

#### Run:
```
source init.sh
make sim
```

### Structure 

### Simulator / Verification
Most smoke tests are written in [cocotb](https://github.com/cocotb/cocotb) which allows the testbenches to be written in python. 
Additionally to this I am learning the basic principals of UVM through Andy Bond's new [AVL project](https://github.com/projectapheleia/avl_beta) currently in beta testing. With this I will be able to more thoroughly test the components through randomised testing and collect coverage on this. 
For running tests I have put together a fairly basic framework to suit the limited needs of this project allowing tests to be defined and configured through `config.yaml` and run with `run_gray_test ...`

Additionally to this using built in system verilog assertions to ensure the designs are not enteted into an invalid state/configuration.  

## Components 

### FIFO:
#### Description:
A basic parameterizable FIFO with a handshake based interface. This also should have full and empty flags.
#### Imlemetation Notes: 
This FIFO is implemented with a read_pointer and write_pointer which have a width of log2 + 1 of the fifo depth. The extra bit can be used to track a wraparound which can help distingush between full and empty. The biggest issue with this is that the depth must be a power of 2 as it uses the implicit addition overflow. A little more logic would be required to make this wraparound flag work for any depth. But for neatness I will leave it as it is for now and add an assertion. 
#### Complete: 
Yes

### Serializer:
#### Description:
On recipt of a valid N-bit input, this module starts to serialise the data marking the start of the packet by setting start high for a single cycle with the first bit of data. 
Enable signal should be high for the entirety of a packet transmission. 
Ready should go high when the module is ready to recieve a new packet, this should be done in a way that there can be back to back packets every N-cycles. ie, no downtime between packet transmissions. 
If a new valid packet arrives before serialisation is complete then the new packet starts to transmit, discarding the old packet. 
#### Imlemetation Notes: 
#### Complete: 
Yes

### De-Serializer:
#### Description:
On a start signal this module takes its single bit data input and collects it into N-bit registers. Once N-bits are recieved the vaild packet is output for a single cycle. If a start comes mid packet then the current packet is discarded and the deserialisation starts on the new packet. 
#### Imlemetation Notes: 
#### Complete: 
Yes 

### SerDes:
#### Description:
Assuming that the Serializer and De-Serializer were correctly implemeted as per the specification then this module should be mostly a wiring job. A valid packet should go in and the same valid packet should come out.
#### Imlemetation Notes: 
#### Complete: 
Yes

### Buffered SerDes:
#### Description:
The SerDes operates on a single clock domain which means the it can only process one packet every N cycles where N == DATA_WIDTH. Therefore if the parallel packets arrive back to back then you can end up dropping packets. Adding a FIFO to the front of it will then allow it to buffer packets as they come in. Whilst the maximum average datarate is unchanged this allows for bursty packets with a requirement for quiet periods for the FIFO to drain. 
#### Imlemetation Notes: 
There is slight friction between the FIFO and the Serializer interfaces. The serializer ready flag is high for the whole time it is ready to take a new packet and it could take multiple cycles for the FIFO to acknowledge the ready and the set the ready low. At which point the FIFO will have sent back to back packets as it can output one packet per cycle. To solve this a small request controller was written that creates a single cycle "ready" pulse unless the fifo is empty then it will hold the ready until data is available.  
For the testbech an AVL constrained random testbench has been written: 
This circuit can only take an average of one packet every 8 cycles.
The fifo enables the ability to buffer the input. 
Here we are constraining the random value of valid to occour just above 1 in 8 cycles therefore will eventually fill up the fifo and drop packets.
Increasing the FIFO depth would increase the amount of time before packets are dropped. 
This would allow for bursty traffic.
#### Complete: 
Yes

### Pulse Generator:
#### Description:
As per the requirents in the "Buffered SerDes" we need a basic module to generate a single cycle pulse to be able to convert the serialisers ready signal which is multi cycle. But if the fifo is empty then the "single cycle" pulse must be held until data is available. 
#### Imlemetation Notes: 
A basic smoke test was written for this and waves visually inspected. Tested in place in buffered SerDes. 
#### Complete: 
Yes

### Sniffer/Corruptor:
#### Description:
This module exists for fun/testing. To add some flavour to the SerDes we can put some sort of packet sniffer on the wire in the middle. This could look out for a specific value. When this value is found we can block the packet, nullify the packet or corrupt the packet. Depending on what this does the latency through this module would vary. For the purpose of the CRC module we are going to corrupt the packet as this will act as a verification tool. As to not affect existing testbenches this is going to be included based on a module parameter. 
#### Imlemetation Notes: 
#### Complete: 
No

### ECC:
#### Description:
For this we will start off with a basic hamming error correction. The exact number of parity bits to data are arbitrary so I am going to decide to send a 32 bit word. Ideally this will be parameterisable so works for different word width/splits. 
Hamming coding can detect up to 2 errors but only correct a single error. For long word lengths this is not ideal, but the longer the word length the higher chance of errors occouring. Additionally in an error caused by some sort of noise, you are likely to get adjacent errors. To work around this you can split your packet into multiple chunks and calculate the hamming code for each chunk. Once the code is included then you can interleave the data which then means that N adjacent bits can be corrected by unraveling the recived data and preforming error correction on the chunks. (Reed solomon coding is known for being able to handle this better and more efficiently but is far more complex so maybe its worth trying that in the future.) 
An additional inefficnency is that hamming codes work most efficently on a packet of size 2^N where N+1 of the bits are used by the code. For example a 64 bit packet can only hold 57 bits of data as 7 bits are used by the code. Therefore to have for example a full 32 bit packet you would need a total of 39 bits.
But in interest of interleaving packets, I am going to do a 32 bit packet but split into two chunks which would mean 32 bits of data + 2 * 6 bits of parity for a total of 42 bits. Not super efficient but thats not the aim of the game. 
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
Yes

### ECC Integration:
#### Description:
Integrate the ECC modules into the serdes. 
Need to work out how best to do this in interest of PPA.
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
Yes

### Register Interface: 

## Possible optimisations discussion: 
    As the goal of this project is to learn, the functionality of this project is not in its most optimal implemetation. In many cases I have thought through how I could do but have traded off doing the typing of implementation for spedning the time widening my exposure to different areas. Here is some analysis on changes that could be made. 
### FIFO: 
    Currently the when the FIFO is empty you must spend a cycle writing to the FIFO before being able to read from it. But in the case where the consumer (serialiser) is ready to read data from the FIFO when the prodcuder has data to send, you can have a bypass path which means that the data never enters the FIFO. This is a good fucntional perfomace optimisation idea in therory but need to be careful in practice as this can make a longer timing path making overall performance and power harder to meet/worse. If latency isn't the aim of the game then there are better things to be done. 
### ECC pipeline: 
    With increased size of packets, the calculation for each of the parity bits gets larger. The parity is caclulated from a bitwise XOR which makes a large XOR tree. If this got too deep then to meet performance then the XOR tree would need to be split up with flop stages to reduce the logic depth.
### ECC Multi-Error:
    This optimisation was described in the ECC module description. In practice what was implemeted was a simple single insance of the hamming encode module. This optimsation would mostly be for "real world" performance. But it would have another benefit of reducing the encoder logic depth without impacting latency at a slight cost of area. 
### ECC just in time: 
    The current integration of the hamming encode just simply puts the encode on the front of the fifo. This means that the word width in the fifo needs to be larger to account for the parity bits. Instead you could peek at the next value to be read from the fifo and calulate the parity bits ready for the next read. This would have an area and power reduction. 
    Doing something like this would become a lot more complicated if you were to have a passthrough fifo. 
    Alternatively there is the option of hiding the encoding in serialisation. This would mean that you would not be able to send the parity bits interleaved as they should be, but would have to send them at the end and re-package before error checking. 
    This would work along side a passthrough fifo. 
### Serial Protocol: 
    The serial protocol being used in this project is very basic with a SOP, valid and data signals. It would be interesting to have used a standardised protocol which sends clock and data together to be able to have two clock domains and using a CDC to sync the recived data into the deserialiser. This sort of protocol tends to have SOP, headers (data length ect), data, EOP. Currently the packet length is hard coded. Having a protocol with clock and data would also make more sense with the sniffer module as this realistically would not live within the same system. 


## Authors

Contributors names and contact info

Lawrence Gray 

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

