// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

VL_INLINE_OPT void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ico_sequent__TOP__0\n"); );
    // Body
    vlSelf->fifo__DOT__clk = vlSelf->clk;
    vlSelf->fifo__DOT__rst_n = vlSelf->rst_n;
    vlSelf->fifo__DOT__data_in = vlSelf->data_in;
    vlSelf->fifo__DOT__write_valid = vlSelf->write_valid;
    vlSelf->fifo__DOT__read_ready = vlSelf->read_ready;
    vlSelf->read_valid = vlSelf->fifo__DOT__read_valid;
    vlSelf->empty = ((IData)(vlSelf->fifo__DOT__rd_idx) 
                     == (IData)(vlSelf->fifo__DOT__wr_idx));
    vlSelf->data_out = ((IData)(vlSelf->fifo__DOT__read_valid)
                         ? (IData)(vlSelf->fifo__DOT__read_data)
                         : 0U);
    vlSelf->fifo__DOT__wr_ptr = (0xfU & (IData)(vlSelf->fifo__DOT__wr_idx));
    vlSelf->fifo__DOT__rd_ptr = (0xfU & (IData)(vlSelf->fifo__DOT__rd_idx));
    vlSelf->fifo__DOT__empty = vlSelf->empty;
    vlSelf->fifo__DOT__data_out = vlSelf->data_out;
    vlSelf->full = (((IData)(vlSelf->fifo__DOT__wr_ptr) 
                     == (IData)(vlSelf->fifo__DOT__rd_ptr)) 
                    & ((1U & ((IData)(vlSelf->fifo__DOT__rd_idx) 
                              >> 4U)) != (1U & ((IData)(vlSelf->fifo__DOT__wr_idx) 
                                                >> 4U))));
    vlSelf->fifo__DOT__full = vlSelf->full;
    vlSelf->write_ready = (1U & (~ (IData)(vlSelf->full)));
    vlSelf->fifo__DOT__write_ready = vlSelf->write_ready;
}

void Vtop___024root___eval_ico(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_ico\n"); );
    // Body
    if ((1ULL & vlSelf->__VicoTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

void Vtop___024root___eval_triggers__ico(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__ico(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__ico\n"); );
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Vtop___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelf->__VicoTriggered.any();
    if (__VicoExecute) {
        Vtop___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vtop___024root___eval_act(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_act\n"); );
}

VL_INLINE_OPT void Vtop___024root___nba_sequent__TOP__0(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___nba_sequent__TOP__0\n"); );
    // Body
    if (vlSelf->rst_n) {
        if (((~ (IData)(vlSelf->empty)) & (IData)(vlSelf->read_ready))) {
            vlSelf->fifo__DOT__rd_idx = (0x1fU & ((IData)(1U) 
                                                  + (IData)(vlSelf->fifo__DOT__rd_idx)));
        }
        if (vlSelf->read_ready) {
            vlSelf->fifo__DOT__read_data = (0xffU & 
                                            (((0U == 
                                               (0x1fU 
                                                & VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__rd_ptr), 3U)))
                                               ? 0U
                                               : (vlSelf->fifo__DOT__fifo_regs[
                                                  (((IData)(7U) 
                                                    + 
                                                    (0x7fU 
                                                     & VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__rd_ptr), 3U))) 
                                                   >> 5U)] 
                                                  << 
                                                  ((IData)(0x20U) 
                                                   - 
                                                   (0x1fU 
                                                    & VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__rd_ptr), 3U))))) 
                                             | (vlSelf->fifo__DOT__fifo_regs[
                                                (3U 
                                                 & (VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__rd_ptr), 3U) 
                                                    >> 5U))] 
                                                >> 
                                                (0x1fU 
                                                 & VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__rd_ptr), 3U)))));
        }
        if (((IData)(vlSelf->write_valid) & (IData)(vlSelf->write_ready))) {
            vlSelf->fifo__DOT__wr_idx = (0x1fU & ((IData)(1U) 
                                                  + (IData)(vlSelf->fifo__DOT__wr_idx)));
            VL_ASSIGNSEL_WI(128,8,(0x7fU & VL_SHIFTL_III(7,32,32, (IData)(vlSelf->fifo__DOT__wr_ptr), 3U)), vlSelf->fifo__DOT__fifo_regs, vlSelf->data_in);
        }
    } else {
        vlSelf->fifo__DOT__wr_idx = 0U;
        vlSelf->fifo__DOT__rd_idx = 0U;
        vlSelf->fifo__DOT__read_data = 0U;
        vlSelf->fifo__DOT__fifo_regs[0U] = 0U;
        vlSelf->fifo__DOT__fifo_regs[1U] = 0U;
        vlSelf->fifo__DOT__fifo_regs[2U] = 0U;
        vlSelf->fifo__DOT__fifo_regs[3U] = 0U;
    }
    vlSelf->fifo__DOT__read_valid = ((IData)(vlSelf->rst_n) 
                                     && ((~ (IData)(vlSelf->empty)) 
                                         & (IData)(vlSelf->read_ready)));
    vlSelf->empty = ((IData)(vlSelf->fifo__DOT__rd_idx) 
                     == (IData)(vlSelf->fifo__DOT__wr_idx));
    vlSelf->fifo__DOT__rd_ptr = (0xfU & (IData)(vlSelf->fifo__DOT__rd_idx));
    if (vlSelf->fifo__DOT__read_valid) {
        vlSelf->read_valid = 1U;
        vlSelf->data_out = vlSelf->fifo__DOT__read_data;
    } else {
        vlSelf->read_valid = 0U;
        vlSelf->data_out = 0U;
    }
    vlSelf->fifo__DOT__empty = vlSelf->empty;
    vlSelf->fifo__DOT__data_out = vlSelf->data_out;
    vlSelf->fifo__DOT__wr_ptr = (0xfU & (IData)(vlSelf->fifo__DOT__wr_idx));
    vlSelf->full = (((IData)(vlSelf->fifo__DOT__wr_ptr) 
                     == (IData)(vlSelf->fifo__DOT__rd_ptr)) 
                    & ((1U & ((IData)(vlSelf->fifo__DOT__rd_idx) 
                              >> 4U)) != (1U & ((IData)(vlSelf->fifo__DOT__wr_idx) 
                                                >> 4U))));
    vlSelf->fifo__DOT__full = vlSelf->full;
    vlSelf->write_ready = (1U & (~ (IData)(vlSelf->full)));
    vlSelf->fifo__DOT__write_ready = vlSelf->write_ready;
}

void Vtop___024root___eval_nba(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_nba\n"); );
    // Body
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vtop___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vtop___024root___eval_triggers__act(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__act(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<1> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtop___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Vtop___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtop___024root___eval_phase__nba(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtop___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelf->__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("/home/lawrence/Documents/Projects/SystemVerilog/CoCo-tb/serdes/rtl/fifo.sv", 1, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Vtop___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelf->__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("/home/lawrence/Documents/Projects/SystemVerilog/CoCo-tb/serdes/rtl/fifo.sv", 1, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Vtop___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("/home/lawrence/Documents/Projects/SystemVerilog/CoCo-tb/serdes/rtl/fifo.sv", 1, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Vtop___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Vtop___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->rst_n & 0xfeU))) {
        Verilated::overWidthError("rst_n");}
    if (VL_UNLIKELY((vlSelf->write_valid & 0xfeU))) {
        Verilated::overWidthError("write_valid");}
    if (VL_UNLIKELY((vlSelf->read_ready & 0xfeU))) {
        Verilated::overWidthError("read_ready");}
}
#endif  // VL_DEBUG
