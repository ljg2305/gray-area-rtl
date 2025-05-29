// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope_fifo);

#ifdef VM_TRACE
    if (__Vm_dumping) _traceDumpClose();
#endif  // VM_TRACE
}

void Vtop__Syms::_traceDump() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    __Vm_dumperp->dump(VL_TIME_Q());
}

void Vtop__Syms::_traceDumpOpen() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    if (VL_UNLIKELY(!__Vm_dumperp)) {
        __Vm_dumperp = new VerilatedVcdC();
        __Vm_modelp->trace(__Vm_dumperp, 0, 0);
        std::string dumpfile = _vm_contextp__->dumpfileCheck();
        __Vm_dumperp->open(dumpfile.c_str());
        __Vm_dumping = true;
    }
}

void Vtop__Syms::_traceDumpClose() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    __Vm_dumping = false;
    VL_DO_CLEAR(delete __Vm_dumperp, __Vm_dumperp = nullptr);
}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", 0, VerilatedScope::SCOPE_OTHER);
    __Vscope_fifo.configure(this, name(), "fifo", "fifo", -9, VerilatedScope::SCOPE_MODULE);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope_fifo);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_TOP.varInsert(__Vfinal,"clk", &(TOP.clk), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"data_in", &(TOP.data_in), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,7,0);
        __Vscope_TOP.varInsert(__Vfinal,"data_out", &(TOP.data_out), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,1 ,7,0);
        __Vscope_TOP.varInsert(__Vfinal,"empty", &(TOP.empty), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"full", &(TOP.full), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"read_ready", &(TOP.read_ready), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"read_valid", &(TOP.read_valid), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"rst_n", &(TOP.rst_n), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"write_ready", &(TOP.write_ready), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"write_valid", &(TOP.write_valid), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"ADDR_WIDTH", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__ADDR_WIDTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"DATA_WIDTH", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__DATA_WIDTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"FIFO_DEPTH", const_cast<void*>(static_cast<const void*>(&(TOP.fifo__DOT__FIFO_DEPTH))), true, VLVT_UINT32,VLVD_NODIR|VLVF_PUB_RW,1 ,31,0);
        __Vscope_fifo.varInsert(__Vfinal,"clk", &(TOP.fifo__DOT__clk), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"data_in", &(TOP.fifo__DOT__data_in), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_fifo.varInsert(__Vfinal,"data_out", &(TOP.fifo__DOT__data_out), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_fifo.varInsert(__Vfinal,"empty", &(TOP.fifo__DOT__empty), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"fifo_regs", &(TOP.fifo__DOT__fifo_regs), false, VLVT_WDATA,VLVD_NODIR|VLVF_PUB_RW,1, 127,0);
        __Vscope_fifo.varInsert(__Vfinal,"full", &(TOP.fifo__DOT__full), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_idx", &(TOP.fifo__DOT__rd_idx), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,4,0);
        __Vscope_fifo.varInsert(__Vfinal,"rd_ptr", &(TOP.fifo__DOT__rd_ptr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_fifo.varInsert(__Vfinal,"read_data", &(TOP.fifo__DOT__read_data), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,7,0);
        __Vscope_fifo.varInsert(__Vfinal,"read_ready", &(TOP.fifo__DOT__read_ready), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"read_valid", &(TOP.fifo__DOT__read_valid), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"rst_n", &(TOP.fifo__DOT__rst_n), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_idx", &(TOP.fifo__DOT__wr_idx), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,4,0);
        __Vscope_fifo.varInsert(__Vfinal,"wr_ptr", &(TOP.fifo__DOT__wr_ptr), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_fifo.varInsert(__Vfinal,"write_ready", &(TOP.fifo__DOT__write_ready), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_fifo.varInsert(__Vfinal,"write_valid", &(TOP.fifo__DOT__write_valid), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
    }
}
