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

    // Apply test values
    dut->A = 1;
    dut->B = int(-(long(1 << 31)));
    dut->alu_ctrl = 0;

    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    vluint64_t clock = 0;
    while (sim_time < MAX_SIM_TIME) {
        clock ^= 1;

        if (clock) {
            posedge_cnt++;
            dut->alu_ctrl = dut->alu_ctrl + 1;
        }

        if (dut->alu_ctrl == 15) {
            break;
        }

        dut->eval();  // Evaluate after changing inputs
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
