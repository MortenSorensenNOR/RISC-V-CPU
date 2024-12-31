// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valu_controller.h for the primary calling header

#include "Valu_controller.h"
#include "Valu_controller__Syms.h"

//==========

void Valu_controller::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Valu_controller::eval\n"); );
    Valu_controller__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("../../src/alu_controller.sv", 3, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Valu_controller::_eval_initial_loop(Valu_controller__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("../../src/alu_controller.sv", 3, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Valu_controller::_combo__TOP__1(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_combo__TOP__1\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->alu_ctrl = ((0U == (IData)(vlTOPp->alu_op))
                         ? 2U : ((1U == (IData)(vlTOPp->alu_op))
                                  ? 6U : ((2U == (IData)(vlTOPp->alu_op))
                                           ? ((0U == (IData)(vlTOPp->funct3))
                                               ? ((0U 
                                                   == (IData)(vlTOPp->funct7))
                                                   ? 2U
                                                   : 6U)
                                               : ((7U 
                                                   == (IData)(vlTOPp->funct3))
                                                   ? 0U
                                                   : 
                                                  ((6U 
                                                    == (IData)(vlTOPp->funct3))
                                                    ? 1U
                                                    : 0xfU)))
                                           : 0xfU)));
}

void Valu_controller::_eval(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_eval\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

VL_INLINE_OPT QData Valu_controller::_change_request(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_change_request\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Valu_controller::_change_request_1(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_change_request_1\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Valu_controller::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((alu_op & 0xfcU))) {
        Verilated::overWidthError("alu_op");}
    if (VL_UNLIKELY((funct7 & 0x80U))) {
        Verilated::overWidthError("funct7");}
    if (VL_UNLIKELY((funct3 & 0xf8U))) {
        Verilated::overWidthError("funct3");}
}
#endif  // VL_DEBUG
