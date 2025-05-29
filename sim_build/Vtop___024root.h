// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtop.h for the primary calling header

#ifndef VERILATED_VTOP___024ROOT_H_
#define VERILATED_VTOP___024ROOT_H_  // guard

#include "verilated.h"


class Vtop__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtop___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    VL_OUT8(full,0,0);
    VL_OUT8(empty,0,0);
    VL_IN8(data_in,7,0);
    VL_OUT8(data_out,7,0);
    VL_IN8(write_valid,0,0);
    VL_OUT8(write_ready,0,0);
    VL_OUT8(read_valid,0,0);
    VL_IN8(read_ready,0,0);
    CData/*0:0*/ fifo__DOT__clk;
    CData/*0:0*/ fifo__DOT__rst_n;
    CData/*0:0*/ fifo__DOT__full;
    CData/*0:0*/ fifo__DOT__empty;
    CData/*7:0*/ fifo__DOT__data_in;
    CData/*7:0*/ fifo__DOT__data_out;
    CData/*0:0*/ fifo__DOT__write_valid;
    CData/*0:0*/ fifo__DOT__write_ready;
    CData/*0:0*/ fifo__DOT__read_valid;
    CData/*0:0*/ fifo__DOT__read_ready;
    CData/*3:0*/ fifo__DOT__rd_ptr;
    CData/*3:0*/ fifo__DOT__wr_ptr;
    CData/*4:0*/ fifo__DOT__rd_idx;
    CData/*4:0*/ fifo__DOT__wr_idx;
    VlWide<4>/*127:0*/ fifo__DOT__fifo_regs;
    CData/*7:0*/ fifo__DOT__read_data;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __VicoFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<1> __VicoTriggered;
    VlTriggerVec<1> __VactTriggered;
    VlTriggerVec<1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vtop__Syms* const vlSymsp;

    // PARAMETERS
    static constexpr IData/*31:0*/ fifo__DOT__DATA_WIDTH = 8U;
    static constexpr IData/*31:0*/ fifo__DOT__FIFO_DEPTH = 0x00000010U;
    static constexpr IData/*31:0*/ fifo__DOT__ADDR_WIDTH = 4U;

    // CONSTRUCTORS
    Vtop___024root(Vtop__Syms* symsp, const char* v__name);
    ~Vtop___024root();
    VL_UNCOPYABLE(Vtop___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
