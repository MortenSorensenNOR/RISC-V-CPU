// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Valu_controller.h for the primary calling header

#include "Valu_controller.h"
#include "Valu_controller__Syms.h"

//==========

VL_CTOR_IMP(Valu_controller) {
    Valu_controller__Syms* __restrict vlSymsp = __VlSymsp = new Valu_controller__Syms(this, name());
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Valu_controller::__Vconfigure(Valu_controller__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-9);
    Verilated::timeprecision(-12);
}

Valu_controller::~Valu_controller() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Valu_controller::_eval_initial(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_eval_initial\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Valu_controller::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::final\n"); );
    // Variables
    Valu_controller__Syms* __restrict vlSymsp = this->__VlSymsp;
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Valu_controller::_eval_settle(Valu_controller__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_eval_settle\n"); );
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void Valu_controller::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Valu_controller::_ctor_var_reset\n"); );
    // Body
    alu_op = VL_RAND_RESET_I(2);
    funct7 = VL_RAND_RESET_I(7);
    funct3 = VL_RAND_RESET_I(3);
    alu_ctrl = VL_RAND_RESET_I(4);
    { int __Vi0=0; for (; __Vi0<1; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
