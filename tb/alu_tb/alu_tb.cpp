#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Valu.h"

#define MAX_SIM_TIME 320
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Valu* dut = new Valu;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Reset inputs
    dut->alu_ctrl = 0;
    dut->A = 0;
    dut->B = 0;
    dut->eval();
    m_trace->dump(sim_time);

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        if (sim_time % 2) {
            posedge_cnt++;

            dut->alu_ctrl = 6;
            dut->A = 2;
            dut->B = 2;
        }

        sim_time++;
        m_trace->dump(sim_time);
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
