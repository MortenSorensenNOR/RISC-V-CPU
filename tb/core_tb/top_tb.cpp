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

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

std::vector<uint32_t> device_mem(DEVICE_MEMORY_SIZE, 0);
int32_t program_end;

void initialize_program_memory(const std::string& fpath) {
    // Insert program
    program_end = 0x0;

    std::ifstream file(fpath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to open file: " << fpath << std::endl;
        return;
    }

    std::string line;
    while (std::getline(file, line)) {
        std::istringstream iss(line);
        uint32_t value;

        // Convert the hex string to a uint32_t
        if (iss >> std::hex >> value) {
            device_mem.at(program_end) = value; // Add to the vector here
            program_end += 0x4;
        } else {
            std::cerr << "Warning: Skipping invalid line: " << line << std::endl;
        }
    }

    program_end = program_end - 0x4;
    printf("program_end: 0x%x\n", program_end);
    file.close();
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vtop* dut = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Apply reset
    initialize_program_memory("test/program.bin");

    dut->clk = 1;
    dut->rstn = 0;
    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();
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

        // printf("\n");
        if (dut->clk == 1) {
            posedge_cnt++;

            vluint32_t PC = dut->top__DOT__core_inst__DOT__if_stage_inst__DOT__PC;
            printf("INSTR: Read  (0x%04x)\t\t", PC);

            // MEM
            if (dut->o_data_mem_write_en) {
                device_mem.at(dut->o_data_mem_addr) = dut->o_data_mem_write_data;
                printf("DATA:  Write (0x%04x):\t0x%04x\t\t", dut->o_data_mem_addr, dut->o_data_mem_write_data);
            }

            if (dut->o_data_mem_read_en) {
                dut->i_data_mem_read_data = device_mem.at(dut->o_data_mem_addr);
                printf("DATA:  Read  (0x%04x):\t0x%04x\t\t", dut->o_data_mem_addr, device_mem.at(dut->o_data_mem_addr));
            }
            printf("\n");


            if (PC == program_end) {
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

