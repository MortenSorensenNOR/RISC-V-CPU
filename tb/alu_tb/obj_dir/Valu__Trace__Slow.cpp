// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Valu__Syms.h"


//======================

void Valu::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Valu::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Valu__Syms* __restrict vlSymsp = static_cast<Valu__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Valu::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Valu::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Valu__Syms* __restrict vlSymsp = static_cast<Valu__Syms*>(userp);
    Valu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Valu::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Valu__Syms* __restrict vlSymsp = static_cast<Valu__Syms*>(userp);
    Valu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBus(c+1,"alu_ctrl", false,-1, 3,0);
        tracep->declBus(c+2,"A", false,-1, 31,0);
        tracep->declBus(c+3,"B", false,-1, 31,0);
        tracep->declBus(c+4,"alu_do", false,-1, 31,0);
        tracep->declBit(c+5,"zero", false,-1);
        tracep->declBit(c+6,"ovf", false,-1);
        tracep->declBus(c+1,"alu alu_ctrl", false,-1, 3,0);
        tracep->declBus(c+2,"alu A", false,-1, 31,0);
        tracep->declBus(c+3,"alu B", false,-1, 31,0);
        tracep->declBus(c+4,"alu alu_do", false,-1, 31,0);
        tracep->declBit(c+5,"alu zero", false,-1);
        tracep->declBit(c+6,"alu ovf", false,-1);
    }
}

void Valu::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Valu::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Valu__Syms* __restrict vlSymsp = static_cast<Valu__Syms*>(userp);
    Valu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Valu::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Valu__Syms* __restrict vlSymsp = static_cast<Valu__Syms*>(userp);
    Valu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->alu_ctrl),4);
        tracep->fullIData(oldp+2,(vlTOPp->A),32);
        tracep->fullIData(oldp+3,(vlTOPp->B),32);
        tracep->fullIData(oldp+4,(vlTOPp->alu_do),32);
        tracep->fullBit(oldp+5,(vlTOPp->zero));
        tracep->fullBit(oldp+6,(vlTOPp->ovf));
    }
}
