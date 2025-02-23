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
#include "../verilator_utils/BranchPredictor.h"

#define MAX_SIM_TIME 123456
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

    // Program interface
    SPI_Master prog_spi_interface;
    int prog_SCK, prog_CSn, prog_MISO, prog_MOSI;
    prog_SCK = 0;
    prog_MISO = 0;
    prog_MOSI = 0;
    prog_CSn = 1;

    // SPI I/O
    SPI_Slave spi_io;

    // BranchPredictor branch_predictor(2, 128);

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
            prog_spi_interface.transfer(0xff);
        }
        dut->load_program = 1;
        while (prog_spi_interface.finished() == 0) {
            dut->clk ^= 1;
            dut->eval();

            prog_spi_interface.update(dut->clk, prog_SCK, prog_CSn, prog_MOSI, prog_MISO);
            dut->mem_loader_SCK = prog_SCK;
            dut->mem_loader_CSn = prog_CSn;
            dut->mem_loader_MOSI = prog_MOSI;

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

        spi_io.update(dut->spi_io_sck, dut->spi_io_csn, dut->spi_io_mosi);

        char c;
        if (spi_io.get_char(c))
            printf("%c", c);

        // if (dut->clk == 0) {
        //     int ex_pc, ex_branch_decision, ex_branch_update;
        //     ex_pc = dut->top__DOT__core_inst__DOT__id_ex_pc;
        //     ex_branch_decision = dut->top__DOT__core_inst__DOT__ex_stage_inst__DOT__w_branch_decision;
        //     ex_branch_update = dut->top__DOT__core_inst__DOT__id_ex_branch || dut->top__DOT__core_inst__DOT__id_ex_jump;
        //     branch_predictor.Update(ex_pc, ex_branch_decision, ex_branch_update);
        //
        //     int id_pc, id_branch, id_jump;
        //     id_pc = dut->top__DOT__core_inst__DOT__if_id_pc;
        //     id_branch = dut->top__DOT__core_inst__DOT__id_stage_inst__DOT__w_id_branch;
        //     id_jump = dut->top__DOT__core_inst__DOT__id_stage_inst__DOT__w_id_jump;
        //
        //     if (id_branch == 1 || id_jump == 1) {
        //         bool branch_prediction = branch_predictor.Predict(id_pc);
        //     }
        // }

        // if (dut->clk) {
        //     if (dut->io_write_en) {
        //         if (dut->io_write_addr == UART_BASE_ADDR) {
        //             printf("%08x\n", dut->io_write_data);
        //         }
        //     }
        // }

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

