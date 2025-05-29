python3 -m venv vvv
source ./vvv/bin/activate

pip install pytest
pip install cocotb
pip install cocotb-test

git clone git@github.com:projectapheleia/avl_beta.git
cd avl_beta
pip install .
cd ..


export PYTHONPATH=${PYTHONPATH}
export SIM=verilator
export TOPLEVEL_LANG=verilog
