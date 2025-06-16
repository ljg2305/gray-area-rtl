python3 -m venv vvv
source ./vvv/bin/activate

pip install pytest
pip install cocotb
pip install cocotb-test
pip install avl-core

#git clone git@github.com:projectapheleia/avl_beta.git
#cd avl_beta
#pip install .
#cd ..


export PYTHONPATH=${PYTHONPATH}
export PYTHONPATH=${PYTHONPATH}:$(pwd)
export PYTHONPATH=${PYTHONPATH}:$(pwd)/packages
export SIM=verilator
export TOPLEVEL_LANG=verilog
