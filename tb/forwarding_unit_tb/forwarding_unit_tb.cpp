#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <error.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vforwarding_unit.h"

enum {
    FORWARD_NONE,
    FORWARD_WB,
    FORWARD_MEM
};

vluint64_t sim_time = 0;

void apply_test_instruction(
        Vforwarding_unit* dut,
        VerilatedVcdC* m_trace,
        int test_case,

        bool mem_reg_write,
        char mem_rd,

        bool wb_reg_write,
        char wb_rd,

        char ex_rs1,
        char ex_rs2,

        char ex_forward_a_expected,
        char ex_forward_b_expected
) {
    dut->mem_reg_write = mem_reg_write;
    dut->mem_rd = mem_rd;

    dut->wb_reg_write = wb_reg_write;
    dut->wb_rd = wb_rd;

    dut->ex_rs1 = ex_rs1;
    dut->ex_rs2 = ex_rs2;
    dut->eval();

    if (int32_t(dut->ex_forward_alu_a) != ex_forward_a_expected) {
        std::cerr << "Test case " << test_case << " failed" << "\t"
                  << " Expected: " << std::dec << int(ex_forward_a_expected) << ", " << int(ex_forward_b_expected) <<  "\t"
                  << " Got: " << int(dut->ex_forward_alu_a) << ", " << int(dut->ex_forward_alu_b) << std::endl;
    } else {
        std::cout << "Test case " << test_case << " passed." << std::endl;
    }
    

    m_trace->dump(sim_time);
    sim_time++;
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vforwarding_unit* dut = new Vforwarding_unit;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Apply reset
    dut->mem_reg_write = 0;
    dut->mem_rd = 0;
    dut->wb_reg_write = 0;
    dut->wb_rd = 0;
    dut->ex_rs1 = 0;
    dut->ex_rs2 = 0;
    m_trace->dump(sim_time);
    sim_time++;

    // Apply test values
    // Test case 1: No forwarding
    apply_test_instruction(dut, m_trace, 1, false, 0, false, 0, 1, 2, FORWARD_NONE, FORWARD_NONE);
    // Test case 2: Forwarding from MEM stage
    apply_test_instruction(dut, m_trace, 2, true, 1, false, 0, 1, 2, FORWARD_MEM, FORWARD_NONE);
    // Test case 3: Forwarding from WB stage
    apply_test_instruction(dut, m_trace, 3, false, 0, true, 1, 2, 1, FORWARD_NONE, FORWARD_WB);
    // Test case 4: Forwarding from MEM and WB stage
    apply_test_instruction(dut, m_trace, 4, true, 1, true, 1, 1, 2, FORWARD_MEM, FORWARD_NONE);
    // Test case 5: Forwarding test with mem_rd = 0
    apply_test_instruction(dut, m_trace, 5, true, 0, false, 0, 0, 2, FORWARD_NONE, FORWARD_NONE);

    m_trace->dump(sim_time);
    sim_time++;

    // Finish simulation
    dut->final();

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
