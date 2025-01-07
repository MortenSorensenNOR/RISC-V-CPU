#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <error.h>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "obj_dir/Vimmediate_generator.h"

void apply_test_instruction(Vimmediate_generator* dut, uint32_t instr, int32_t expected_imm) {
    dut->instruction = instr;
    dut->eval();

    if (int32_t(dut->imm) != expected_imm) {
        std::cerr << "Test failed for instruction: 0x" << std::hex << int32_t(instr) << "\t"
                  << " Expected: " << std::dec << expected_imm
                  << " Got: " << dut->imm << std::endl << std::endl;
    } else {
        std::cout << "Test passed for instruction: 0x" << std::hex << instr << std::endl << std::endl;
    }
}

int main(int argc, char* argv[]) {
    Verilated::commandArgs(argc, argv);
    Vimmediate_generator* dut = new Vimmediate_generator;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    // Apply test values
    apply_test_instruction(dut, 0x00A00513, 10);       // I-type: ADDI
    apply_test_instruction(dut, 0xFFF00793, -1);       // I-type: ADDI
    apply_test_instruction(dut, 0x00408063, 8);        // B-type: BEQ
    apply_test_instruction(dut, 0xFF1FF06F, -452);     // J-type: JAL
    apply_test_instruction(dut, 0x00C000EF, 12);       // J-type: JAL

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
