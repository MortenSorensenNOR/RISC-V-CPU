#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Valu_controller.h"

#define MAX_SIM_TIME 320
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void eval_and_step(Valu_controller* dut, VerilatedVcdC* m_trace) {
    dut->eval();
    sim_time++;
    m_trace->dump(sim_time);
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Valu_controller* dut = new Valu_controller;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Reset inputs
    dut->alu_op = 0;
    dut->funct7 = 0;
    dut->funct3 = 0;
    eval_and_step(dut, m_trace);
    eval_and_step(dut, m_trace);
    eval_and_step(dut, m_trace);

    dut->alu_op = 1;
    dut->funct7 = 0;
    dut->funct3 = 0;
    eval_and_step(dut, m_trace);
    dut->funct7 = 4;
    dut->funct3 = 3;
    eval_and_step(dut, m_trace);
    dut->funct7 = 2;
    dut->funct3 = 5;
    eval_and_step(dut, m_trace);
    dut->funct7 = 14;
    dut->funct3 = 1;
    eval_and_step(dut, m_trace);

    dut->alu_op = 2;
    dut->funct7 = 0;
    dut->funct3 = 0;
    eval_and_step(dut, m_trace);
    dut->funct7 = 0b0100000;
    dut->funct3 = 0;
    eval_and_step(dut, m_trace);
    dut->funct7 = 0;
    dut->funct3 = 7;
    eval_and_step(dut, m_trace);
    dut->funct7 = 0;
    dut->funct3 = 6;
    eval_and_step(dut, m_trace);
    eval_and_step(dut, m_trace);
    eval_and_step(dut, m_trace);

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
