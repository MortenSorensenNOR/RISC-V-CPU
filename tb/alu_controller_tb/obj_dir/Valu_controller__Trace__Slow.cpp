// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Valu_controller__Syms.h"


//======================

void Valu_controller::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Valu_controller::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Valu_controller::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Valu_controller::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Valu_controller::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"alu_op", false,-1, 1,0);
        tracep->declBus(c+2,"funct7", false,-1, 6,0);
        tracep->declBus(c+3,"funct3", false,-1, 2,0);
        tracep->declBus(c+4,"alu_ctrl", false,-1, 3,0);
        tracep->declBus(c+1,"alu_controller alu_op", false,-1, 1,0);
        tracep->declBus(c+2,"alu_controller funct7", false,-1, 6,0);
        tracep->declBus(c+3,"alu_controller funct3", false,-1, 2,0);
        tracep->declBus(c+4,"alu_controller alu_ctrl", false,-1, 3,0);
    }
}

void Valu_controller::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Valu_controller::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Valu_controller::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Valu_controller__Syms* __restrict vlSymsp = static_cast<Valu_controller__Syms*>(userp);
    Valu_controller* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->alu_op),2);
        tracep->fullCData(oldp+2,(vlTOPp->funct7),7);
        tracep->fullCData(oldp+3,(vlTOPp->funct3),3);
        tracep->fullCData(oldp+4,(vlTOPp->alu_ctrl),4);
    }
}
