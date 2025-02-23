`timescale 1ns/1ps

/* verilator lint_off UNUSED */
module i_mem #(
    parameter unsigned MEMORY_SIZE = 8196, // Bytes
    parameter string PROGRAM_PATH = "test/program.bin"
) (
    input logic clk,

    input  logic [31:0] addr,
    output logic [31:0] instr,

    input logic [31:0]  mem_loader_write_addr,
    input logic [7:0]   mem_loader_write_data,
    input logic         mem_loader_write_en
);

    logic [7:0] i_mem[MEMORY_SIZE];
    initial begin
        if (PROGRAM_PATH != "") begin
            $readmemh(PROGRAM_PATH, i_mem);
        end
    end

    // Load program from external device
    always_ff @(posedge clk) begin
        if (mem_loader_write_en) begin
            i_mem[mem_loader_write_addr] <= mem_loader_write_data;
        end
    end

    // Assign instruction from memory
    always_comb begin
        instr = {i_mem[addr+3], i_mem[addr+2], i_mem[addr+1], i_mem[addr]};
    end

endmodule
