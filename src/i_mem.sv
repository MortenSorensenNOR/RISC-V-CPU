`timescale 1ns/1ps

/* verilator lint_off UNUSED */
module i_mem #(
    parameter unsigned MEMORY_SIZE = 8196, // Bytes
    parameter string PROGRAM_PATH = "test/program.bin"
) (
    input logic [31:0] addr,
    output logic [31:0] instr
);

    logic [7:0] mem[MEMORY_SIZE];

    initial begin
        if (PROGRAM_PATH != "") begin
            $readmemh(PROGRAM_PATH, mem);
        end
    end

    always_comb begin
        instr = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
    end

endmodule
