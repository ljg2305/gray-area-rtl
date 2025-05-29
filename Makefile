# Makefile

# defaults
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

export PYTHONPATH := $(PWD)/testbench:$(PYTHONPATH)

VERILOG_SOURCES += $(PWD)/rtl/fifo.sv
VERILOG_SOURCES += $(PWD)/rtl/pulse_gen.sv
VERILOG_SOURCES += $(PWD)/rtl/serdes.sv 
VERILOG_SOURCES += $(PWD)/rtl/serdes_fifo.sv 
VERILOG_SOURCES += $(PWD)/rtl/serializer.sv 
VERILOG_SOURCES += $(PWD)/rtl/deserializer.sv 


# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
#TOPLEVEL = serdes_fifo
#TOPLEVEL = pulse_gen
TOPLEVEL = fifo

# MODULE is the basename of the Python test file
MODULE = fifo_avl_testbench
#MODULE = serdes_testbench
#MODULE = serdes_fifo_testbench
#MODULE = pulse_testbench

EXTRA_ARGS     += --trace --trace-structs

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

