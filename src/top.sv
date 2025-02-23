`timescale 1ns/1ps

module top (
    input logic clk,
    input logic rstn,

    // // Easy debugging
    // output logic [31:0] io_write_addr,
    // output logic [31:0] io_write_data,
    // output logic io_write_en,

    // For loading programs into instruction memory from external device
    input logic  load_program,
    input logic  mem_loader_SCK,
    input logic  mem_loader_CSn,
    input logic  mem_loader_MOSI,
    output logic mem_loader_MISO,

    // SPI I/O
    output logic spi_io_sck,
    output logic spi_io_mosi,
    output logic spi_io_csn

);

    // Program loader
    logic core_program_resetn;
    logic [7:0] mem_loader_mem_write_data;
    logic [31:0] mem_loader_mem_write_addr;
    logic mem_loader_mem_write_en;

    spi_program_loader spi_program_loader_inst (
        .clk(clk),
        .rstn(rstn),

        .load_program(load_program),
        .core_program_resetn(core_program_resetn),

        .mem_write_addr(mem_loader_mem_write_addr),
        .mem_write_data(mem_loader_mem_write_data),
        .mem_write_en(mem_loader_mem_write_en),

        .SCK(mem_loader_SCK),
        .CSn(mem_loader_CSn),
        .MOSI(mem_loader_MOSI),
        .MISO(mem_loader_MISO)
    );

    // Instruction Memory
    localparam string PROGRAM_PATH = "../programs/program.hex"; // test/program.bin
    logic [31:0] instr_mem_addr;
    logic [31:0] instr_mem_instr;

    i_mem #(
        .MEMORY_SIZE(512),
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
    logic [3:0]  data_mem_data_mask;
    logic data_mem_write_en;
    logic data_mem_read_en;
    logic [31:0] data_mem_read_data;

    d_mem #(
        .MEMORY_SIZE(512)
    ) data_memory_instr (
        .clk(clk),
        .addr(data_mem_addr),
        .write_data(data_mem_write_data),
        .data_mask(data_mem_data_mask),
        .write_en(data_mem_write_en),
        .read_en(data_mem_read_en),

        .read_data(data_mem_read_data)
    );

    // SPI I/O
    logic [7:0] spi_io_status;
    logic       spi_io_status_write_en;

    spi_io #(
        .CLKS_PER_HALF_BIT(5),
        .SPI_IO_ADDR(32'h80000000)
    ) spi_io_inst (
        .clk(clk),
        .rstn(rstn),

        .mem_bus_addr(data_mem_addr),
        .mem_bus_data(data_mem_write_data),
        .mem_bus_write_en(data_mem_write_en),
        .mem_bus_data_mask(data_mem_data_mask),

        .mem_bus_read_en(data_mem_read_en),
        .mem_bus_spi_status(spi_io_status),
        .mem_bus_spi_status_write_en(spi_io_status_write_en),

        .o_spi_sck(spi_io_sck),
        .o_spi_mosi(spi_io_mosi),
        .o_spi_csn(spi_io_csn)
    );

    // Core
    logic core_resetn;
    assign core_resetn = rstn & core_program_resetn;

    // In order to give SPI status precedence
    logic [31:0] core_data_mem_read_data;

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
        .i_data_mem_read_data(core_data_mem_read_data)
    );

    // In order to do SPI status stuff, the SPI status has to have precedence
    // (for now) over the data memory bus
    always_comb begin
        if (spi_io_status_write_en) begin
            core_data_mem_read_data = {{24{1'b0}}, spi_io_status};
        end else begin
            core_data_mem_read_data = data_mem_read_data;
        end
    end

    // // DEBUG
    // assign io_write_addr = data_mem_addr;
    // assign io_write_data = data_mem_write_data;
    // assign io_write_en   = data_mem_write_en;

endmodule
