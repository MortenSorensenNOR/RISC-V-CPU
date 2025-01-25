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

#include "../verilator_utils/SPI.h"

#define MAX_SIM_TIME 256
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

    SPI_Master spi_interface;
    int SCK, CSn, MISO, MOSI;
    SCK = 0;
    MISO = 0;
    MOSI = 0;
    CSn = 1;

    // Reset
    dut->clk = 1;
    dut->rstn = 0;
    for (int i = 0; i < RESET_CLKS; i++) {
        dut->clk ^= 1;
        dut->eval();

        dut->mem_loader_SCK = 0;
        dut->mem_loader_CSn = 1;
        dut->mem_loader_MOSI = 0;

        m_trace->dump(sim_time);
        sim_time++;
    }
    dut->rstn = 1;

    // Set program memory
    bool use_spi_program_load = false;
    if (use_spi_program_load) {
        for (int i = 0; i < 128; i++) {
            spi_interface.transfer(0xff);
        }
        dut->load_program = 1;
        while (spi_interface.finished() == 0) {
            dut->clk ^= 1;
            dut->eval();

            spi_interface.update(dut->clk, SCK, CSn, MOSI, MISO);
            dut->mem_loader_SCK = SCK;
            dut->mem_loader_CSn = CSn;
            dut->mem_loader_MOSI = MOSI;

            m_trace->dump(sim_time);
            sim_time++;
        }
        // Ensure the program has finished writing
        for (int i = 0; i < 32; i++) {
            dut->clk ^= 1;
            dut->eval();
            m_trace->dump(sim_time);
            sim_time++;
        }
        dut->load_program = 0;
    }

    // Simulation
    vluint64_t finished_clock = -1;
    vluint64_t start = sim_time;
    while (sim_time < MAX_SIM_TIME + start) {
        dut->clk ^= 1;
        dut->eval();

        if (dut->clk) {
            // Will use spi in the end, but for now, just get values directly
            if (dut->io_write_en) {
                if (dut->io_write_addr == UART_BASE_ADDR) {
                    printf("%c", dut->io_write_data & 0xff);
                }
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

