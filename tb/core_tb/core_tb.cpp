#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <vector>
#include <error.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vcore.h"

#define MAX_SIM_TIME 128
#define RESET_CLKS 8
#define DEVICE_MEMORY_SIZE 8192 // Bytes

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;
std::vector<uint32_t> device_mem(DEVICE_MEMORY_SIZE / 4, 0);
int32_t program_end;

void reset_device_memory() {
    // Insert program
    device_mem.at(0x0) = 0x800002b7;    // auipc x5, -524288
    device_mem.at(0x4) = 0xfff28293;    // addi x5, x5, -1
    device_mem.at(0x8) = 0x07b00093;    // addi x1, x0, 123
    device_mem.at(0xc) = 0xff600113;    // addi x2, x0, -10
    device_mem.at(0x10) = 0x002081b3;   // add x3, x1, x2
    device_mem.at(0x14) = 0x123021a3;   // sw x3, 0x123(x0)
    device_mem.at(0x18) = 0x12302203;   // lw x4, 0x123(x0)
    device_mem.at(0x1c) = 0x105028a3;   // sw x5, 0x111(x0)
    program_end = 0x1c;
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vcore* dut = new Vcore;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Apply reset
    reset_device_memory();

    dut->clk = 1;
    dut->rstn = 0;
    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();

        dut->i_instr_mem_read_data = 0;
        dut->i_data_mem_read_data  = 0;

        m_trace->dump(sim_time);
        sim_time++;
    }
    dut->rstn = 1;

    // Simulation
    vluint64_t finished_clock = -1;
    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();

        if (dut->clk == 1) {
            posedge_cnt++;

            // Assign instruction
            dut->i_instr_mem_read_data = device_mem.at(dut->o_instr_mem_read_addr);
            printf("INSTR: Read (0x%08x):\t0x%08x\t\t", dut->o_instr_mem_read_addr, device_mem.at(dut->o_instr_mem_read_addr));

            // MEM
            if (dut->o_data_mem_write_en) {
                device_mem.at(dut->o_data_mem_addr) = dut->o_data_mem_write_data;
                printf("DATA: Write (0x%08x):\t0x%08x\t\t", dut->o_data_mem_addr, dut->o_data_mem_write_data);
            }

            if (dut->o_data_mem_read_en) {
                dut->i_data_mem_read_data = device_mem.at(dut->o_data_mem_addr);
                printf("DATA: Read  (0x%08x):\t0x%08x\t\t", dut->o_data_mem_addr, device_mem.at(dut->o_data_mem_addr));
            }
            printf("\n");

            if (dut->o_instr_mem_read_addr == program_end) {
                finished_clock = posedge_cnt + 4;
            }

            if (posedge_cnt == finished_clock) {
                break;
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
