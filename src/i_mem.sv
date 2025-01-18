`timescale 1ns/1ps

/* verilator lint_off UNUSED */
module i_mem #(
    parameter string PROGRAM_PATH = "test/program.bin"
) (
    input logic [31:0] addr,
    output logic [31:0] instr
);

    localparam unsigned MemSize = 8196;
    logic [31:0] mem[MemSize];

    initial begin
        $readmemh(PROGRAM_PATH, mem);
    end

    logic [$clog2(MemSize)-1:0] w_memory_addr;
    assign w_memory_addr = addr[$clog2(MemSize) + 1 : 2];
    assign instr = mem[w_memory_addr];

endmodule
