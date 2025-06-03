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
#### Specification: 
#### Imlemetation Notes: 
This FIFO is implemented with a read_pointer and write_pointer which have a width of log2 + 1 of the fifo depth. The extra bit can be used to track a wraparound which can help distingush between full and empty. The biggest issue with this is that the depth must be a power of 2 as it uses the implicit addition overflow. A little more logic would be required to make this wraparound flag work for any depth. But for neatness I will leave it as it is for now and add an assertion. 
#### Complete: 
Yes

### Async FIFO: 
#### Description:
Same as FIFO but updated to use graycoding and distance based logic. 
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
No

### Serializer:
#### Description:
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
Yes

### De-Serializer:
#### Description:
Assuming that the Serializer and De-Serializer were correctly implemeted as per the specification then this module should be mostly a wiring job. A valid packet should go in and the same valid packet should come out.
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
Yes 

### SerDes:
#### Description:
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
Yes

### Buffered SerDes:
#### Description:
The SerDes operates on a single clock domain which means the it can only process one packet every N cycles where N == DATA_WIDTH. Therefore if the parallel packets arrive back to back then you can end up dropping packets. Adding a FIFO to the front of it will then allow it to buffer packets as they come in. Whilst the maximum average datarate is unchanged this allows for bursty packets with a requirement for quiet periods for the FIFO to drain. 
#### Specification: 
#### Imlemetation Notes: 
There is slight friction between the FIFO and the Serializer interfaces. The serializer ready flag is high for the whole time it is ready to take a new packet and it could take multiple cycles for the FIFO to acknowledge the ready and the set the ready low. At which point the FIFO will have sent back to back packets as it can output one packet per cycle. To solve this a small request controller was written that creates a single cycle "ready" pulse unless the fifo is empty then it will hold the ready until data is available.  
#### Complete: 
No

### Sniffer:
#### Description:
To add some flavour to the SerDes we can put some sort of packet sniffer on the wire in the middle. This could look out for a specific value. When this value is found we can block the packet, nullify the packet or corrupt the packet. Depending on what this does the latency through this module would vary. For the purpose of the CRC module we are going to corrupt the packet as this will act as a verification tool. As to not affect existing testbenches this is going to be included based on a module parameter. 
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
No

### CRC:
#### Description:
#### Specification: 
#### Imlemetation Notes: 
#### Complete: 
No

## Authors

Contributors names and contact info

Lawrence Gray 

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

