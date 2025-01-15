#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <error.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "obj_dir/Vid_ex_tb.h"

vluint64_t sim_time = 0;

void apply_test_instruction(Vid_ex_tb* dut,
                            VerilatedVcdC* m_trace,
                            uint32_t instr,
                            int32_t rd1,
                            int32_t rd2,
                            int32_t pc,
                            int32_t expected_alu_result,
                            bool    test_alu_result) {
    dut->instr = instr;
    dut->rd1 = rd1;
    dut->rd2 = rd2;
    dut->pc  = pc;
    dut->eval();

    if (test_alu_result) {
        if (int32_t(dut->AluResult) != expected_alu_result) {
            std::cerr << "Test failed for instruction: 0x" << std::hex << int32_t(instr) << "\t"
                      << " Expected AluResult: " << std::dec << expected_alu_result
                      << " Got: " << dut->AluResult << std::endl;
        } else {
            std::cout << "Test passed for instruction: 0x" << std::hex << instr << std::endl;
        }
    }

    m_trace->dump(sim_time);
    sim_time++;
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vid_ex_tb* dut = new Vid_ex_tb;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Apply reset
    dut->instr = 0;
    dut->rd1 = 0;
    dut->rd2 = 0;
    dut->pc = 0;

    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    // add x1, x2(5), x3(-1)
    apply_test_instruction(dut, m_trace, 0x003100b3, 5, -1, 0x0, 4, true);
    // add x1, x2(-1), x3(-1)
    apply_test_instruction(dut, m_trace, 0x003100b3, -1, -1, 0x0, -2, true);
    // addi x1, x2(12345), -1
    apply_test_instruction(dut, m_trace, 0xf8510093, 12345, 0, 0x0, 12222, true);
    // and x1, x2(0xf), x3(0x1234)
    apply_test_instruction(dut, m_trace, 0x003170b3, 0xf0f, 0x1234, 0x0, 516, true);
    // sw x1(16), 0x1234(x2) -- x2 = 0x1111
    apply_test_instruction(dut, m_trace, 0x40113023, 512, 16, 0x0, 1536, true);
    // jalr x1, 0x128(x2,  -- x2 = -512
    apply_test_instruction(dut, m_trace, 0x128100e7, -128, 0, 0x0, 168, true);
    // lui
    apply_test_instruction(dut, m_trace, 0x012340b7, 0, 0, 0x123456, 0x1234000, true);
    // auipc 
    apply_test_instruction(dut, m_trace, 0x01234097, 0, 0, 0x123456, 0x1357456, true);

    // Finish simulation
    m_trace->dump(sim_time);
    sim_time++;
    dut->final();

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
