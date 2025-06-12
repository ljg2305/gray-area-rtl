import os
import yaml
from cocotb_test.simulator import run

def load_config():
    with open("config.yaml", "r") as f:
        config = yaml.safe_load(f)
    return config

def gray_test_template(toplevel,testbench_module):
    config = load_config()
    run(
        verilog_sources=config['global']['verilog_sources'],
        toplevel=toplevel,
        module=testbench_module,  
        extra_args=["--trace"],
        waves=True               # Tells cocotb-test to expect waveform output]
    )