// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Valu_controller__Syms.h"


void Valu_controller::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Valu_controller::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->chgCData(oldp+0,(vlTOPp->alu_op),2);
        tracep->chgCData(oldp+1,(vlTOPp->funct7),7);
        tracep->chgCData(oldp+2,(vlTOPp->funct3),3);
        tracep->chgCData(oldp+3,(vlTOPp->alu_ctrl),4);
    }
}

void Valu_controller::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
    }
}
