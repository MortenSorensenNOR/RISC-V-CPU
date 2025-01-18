`timescale 1ns/1ps

module top (
    input logic clk,
    input logic rstn,

    // MEM
    output logic [31:0] o_data_mem_addr,
    output logic [31:0] o_data_mem_write_data,
    output logic o_data_mem_read_en,
    output logic o_data_mem_write_en,
    input logic  [31:0] i_data_mem_read_data
);

    localparam string PROGRAM_PATH = "test/program.bin";

    logic [31:0] i_mem_addr;
    logic [31:0] i_mem_instr;
    i_mem #(
        .PROGRAM_PATH(PROGRAM_PATH)
    ) instruction_mememory_inst (
        .addr(i_mem_addr),
        .instr(i_mem_instr)
    );

    core core_inst (
        .clk(clk),
        .rstn(rstn),

        .o_instr_mem_read_addr(i_mem_addr),
        .i_instr_mem_read_data(i_mem_instr),

        .o_data_mem_addr(o_data_mem_addr),
        .o_data_mem_write_data(o_data_mem_write_data),
        .o_data_mem_read_en(o_data_mem_read_en),
        .o_data_mem_write_en(o_data_mem_write_en),
        .i_data_mem_read_data(i_data_mem_read_data)
    );

endmodule
