`timescale 1ns/1ps

module top (
    input logic clk,
    input logic rstn,

    // For loading programs into instruction memory from external device
    input logic mem_loader_write_en,
    input logic mem_loader_SCK,
    input logic mem_loader_CSn,
    input logic mem_loader_MOSI,
    output logic mem_loader_MISO

    // // For basic I/O using same addr/data buss as memory
    // //      -- for now just writes
    // output logic [31:0] io_write_addr,
    // output logic io_write_en,
    // output logic [31:0] io_write_data
);

    // Program loader
    logic core_load_resetn;
    logic [7:0] mem_loader_mem_write_data;
    logic [31:0] mem_loader_mem_write_addr;
    logic mem_loader_mem_write_en;

    spi_program_loader spi_program_loader_inst (
        .clk(clk),
        .rstn(rstn),

        .device_mem_write_en(mem_loader_write_en),
        .core_load_resetn(core_load_resetn),

        .mem_write_addr(mem_loader_mem_write_addr),
        .mem_write_data(mem_loader_mem_write_data),
        .mem_write_en(mem_loader_mem_write_en),

        .device_SCK(mem_loader_SCK),
        .device_CSn(mem_loader_CSn),
        .device_MOSI(mem_loader_MOSI),
        .device_MISO(mem_loader_MISO)
    );

    // Instruction Memory
    localparam string PROGRAM_PATH = "test/program.bin";
    logic [31:0] instr_mem_addr;
    logic [31:0] instr_mem_instr;

    i_mem #(
        .MEMORY_SIZE(8196),
        .PROGRAM_PATH(PROGRAM_PATH)
    ) instruction_mememory_inst (
        .clk(clk),

        .addr(instr_mem_addr),
        .instr(instr_mem_instr),

        .mem_loader_write_addr(mem_loader_mem_write_addr),
        .mem_loader_write_data(mem_loader_mem_write_data),
        .mem_loader_write_en(mem_loader_mem_write_en)
    );

    // Data Memory
    logic [31:0] data_mem_addr;
    logic [31:0] data_mem_write_data;
    logic [1:0]  data_mem_data_mask;
    logic data_mem_write_en;
    logic data_mem_read_en;
    logic [31:0] data_mem_read_data;

    d_mem #(
        .MEMORY_SIZE(8196)
    ) data_memory_instr (
        .clk(clk),
        .addr(data_mem_addr),
        .write_data(data_mem_write_data),
        .data_mask(data_mem_data_mask),
        .write_en(data_mem_write_en),
        .read_en(data_mem_read_en),

        .read_data(data_mem_read_data)
    );

    // Core
    logic core_resetn;
    assign core_resetn = rstn & core_load_resetn;

    core core_inst (
        .clk(clk),
        .rstn(core_resetn),

        .o_instr_mem_read_addr(instr_mem_addr),
        .i_instr_mem_read_data(instr_mem_instr),

        .o_data_mem_addr(data_mem_addr),
        .o_data_mem_write_data(data_mem_write_data),
        .o_data_mem_write_en(data_mem_write_en),
        .o_data_mem_read_en(data_mem_read_en),
        .o_data_mem_data_mask(data_mem_data_mask),
        .i_data_mem_read_data(data_mem_read_data)
    );

endmodule
