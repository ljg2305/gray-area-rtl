// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtop___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelf->clk));
    bufp->chgBit(oldp+1,(vlSelf->rst_n));
    bufp->chgBit(oldp+2,(vlSelf->full));
    bufp->chgBit(oldp+3,(vlSelf->empty));
    bufp->chgCData(oldp+4,(vlSelf->data_in),8);
    bufp->chgCData(oldp+5,(vlSelf->data_out),8);
    bufp->chgBit(oldp+6,(vlSelf->write_valid));
    bufp->chgBit(oldp+7,(vlSelf->write_ready));
    bufp->chgBit(oldp+8,(vlSelf->read_valid));
    bufp->chgBit(oldp+9,(vlSelf->read_ready));
    bufp->chgBit(oldp+10,(vlSelf->fifo__DOT__clk));
    bufp->chgBit(oldp+11,(vlSelf->fifo__DOT__rst_n));
    bufp->chgBit(oldp+12,(vlSelf->fifo__DOT__full));
    bufp->chgBit(oldp+13,(vlSelf->fifo__DOT__empty));
    bufp->chgCData(oldp+14,(vlSelf->fifo__DOT__data_in),8);
    bufp->chgCData(oldp+15,(vlSelf->fifo__DOT__data_out),8);
    bufp->chgBit(oldp+16,(vlSelf->fifo__DOT__write_valid));
    bufp->chgBit(oldp+17,(vlSelf->fifo__DOT__write_ready));
    bufp->chgBit(oldp+18,(vlSelf->fifo__DOT__read_valid));
    bufp->chgBit(oldp+19,(vlSelf->fifo__DOT__read_ready));
    bufp->chgCData(oldp+20,(vlSelf->fifo__DOT__rd_ptr),4);
    bufp->chgCData(oldp+21,(vlSelf->fifo__DOT__wr_ptr),4);
    bufp->chgCData(oldp+22,(vlSelf->fifo__DOT__rd_idx),5);
    bufp->chgCData(oldp+23,(vlSelf->fifo__DOT__wr_idx),5);
    bufp->chgCData(oldp+24,((0xffU & vlSelf->fifo__DOT__fifo_regs[0U])),8);
    bufp->chgCData(oldp+25,((0xffU & (vlSelf->fifo__DOT__fifo_regs[0U] 
                                      >> 8U))),8);
    bufp->chgCData(oldp+26,((0xffU & (vlSelf->fifo__DOT__fifo_regs[0U] 
                                      >> 0x10U))),8);
    bufp->chgCData(oldp+27,((vlSelf->fifo__DOT__fifo_regs[0U] 
                             >> 0x18U)),8);
    bufp->chgCData(oldp+28,((0xffU & vlSelf->fifo__DOT__fifo_regs[1U])),8);
    bufp->chgCData(oldp+29,((0xffU & (vlSelf->fifo__DOT__fifo_regs[1U] 
                                      >> 8U))),8);
    bufp->chgCData(oldp+30,((0xffU & (vlSelf->fifo__DOT__fifo_regs[1U] 
                                      >> 0x10U))),8);
    bufp->chgCData(oldp+31,((vlSelf->fifo__DOT__fifo_regs[1U] 
                             >> 0x18U)),8);
    bufp->chgCData(oldp+32,((0xffU & vlSelf->fifo__DOT__fifo_regs[2U])),8);
    bufp->chgCData(oldp+33,((0xffU & (vlSelf->fifo__DOT__fifo_regs[2U] 
                                      >> 8U))),8);
    bufp->chgCData(oldp+34,((0xffU & (vlSelf->fifo__DOT__fifo_regs[2U] 
                                      >> 0x10U))),8);
    bufp->chgCData(oldp+35,((vlSelf->fifo__DOT__fifo_regs[2U] 
                             >> 0x18U)),8);
    bufp->chgCData(oldp+36,((0xffU & vlSelf->fifo__DOT__fifo_regs[3U])),8);
    bufp->chgCData(oldp+37,((0xffU & (vlSelf->fifo__DOT__fifo_regs[3U] 
                                      >> 8U))),8);
    bufp->chgCData(oldp+38,((0xffU & (vlSelf->fifo__DOT__fifo_regs[3U] 
                                      >> 0x10U))),8);
    bufp->chgCData(oldp+39,((vlSelf->fifo__DOT__fifo_regs[3U] 
                             >> 0x18U)),8);
    bufp->chgCData(oldp+40,(vlSelf->fifo__DOT__read_data),8);
}

void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_cleanup\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
