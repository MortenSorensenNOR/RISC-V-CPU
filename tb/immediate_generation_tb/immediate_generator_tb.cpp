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
                  << " Got: " << dut->imm << std::endl;
    } else {
        std::cout << "Test passed for instruction: 0x" << std::hex << instr << std::endl;
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
    apply_test_instruction(dut, 0xf8500313, -123);          // I-type: ADDI
    apply_test_instruction(dut, 0x4d200313, 1234);          // I-type: ADDI
    apply_test_instruction(dut, 0xb220a723, -1234);         // S-type: SW
    apply_test_instruction(dut, 0x12100163, 290);           // B-type: BEQ
    apply_test_instruction(dut, 0x344120ef, 74564);         // J-type: JAL
    apply_test_instruction(dut, 0xb2fff0ef, -1234);         // J-type: JAL
    apply_test_instruction(dut, 0x4d2100e7, 1234);          // I-type: JALR
    apply_test_instruction(dut, 0x01234037, 0x1234 << 12);  // U-type: LUI

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);


    return 0;
}
