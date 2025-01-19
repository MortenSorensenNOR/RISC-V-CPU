#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <error.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vtop.h"

#define MAX_SIM_TIME 128
#define RESET_CLKS 8
#define DEVICE_MEMORY_SIZE 8192 // * 4 Bytes

#define UART_BASE_ADDR 0x80000000

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vtop* dut = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->clk = 1;
    dut->rstn = 0;
    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }
    dut->rstn = 1;

    // Simulation
    vluint64_t finished_clock = -1;
    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();

        // printf("\n");
        if (dut->clk == 1) {
            posedge_cnt++;

            vluint32_t PC = dut->top__DOT__core_inst__DOT__if_stage_inst__DOT__PC;

            // Basic I/O
            if (dut->io_write_en && dut->io_write_addr == UART_BASE_ADDR) {
                printf("%c\n", dut->io_write_data & 0xff);
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    // Finish simulation
    m_trace->dump(sim_time);
    sim_time++;
    dut->final();

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

