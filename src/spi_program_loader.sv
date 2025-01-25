`timescale 1ns/1ps

module spi_program_loader (
    input logic clk,
    input logic rstn,

    // Enable write to instruction/data memory
    input  logic load_program,          // External signal to initiate write
    output logic core_program_resetn,

    // Data to write to memory -- make it simple, start write at 0x0 and
    // iterate with one byte at a time
    output logic [31:0] mem_write_addr,
    output logic [7:0]  mem_write_data,
    output logic mem_write_en,

    // SPI signals from external Raspberry PI
    input  logic SCK,
    input  logic CSn,
    input  logic MOSI,
    output logic MISO
);

    // SPI Module
    logic [7:0] spi_rx_data;
    logic spi_rx_valid;
    spi_slave spi_slave_inst (
        .clk(clk),
        .rstn(rstn),

        .RX_Byte(spi_rx_data),
        .RX_Valid(spi_rx_valid),

        .MOSI(MOSI),
        .MISO(MISO),
        .SCK(SCK),
        .CSn(CSn)
    );

    // Write logic
    logic [31:0] next_mem_write_addr;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            mem_write_data <= '0;
            mem_write_en <= '0;
            mem_write_addr <= '0;
            next_mem_write_addr <= '0;
        end else begin
            if (load_program) begin
                if (spi_rx_valid) begin
                    mem_write_data <= spi_rx_data;
                    mem_write_addr <= next_mem_write_addr;
                    next_mem_write_addr <= next_mem_write_addr + 1;
                    mem_write_en <= spi_rx_valid;
                end else begin
                    mem_write_data <= '0;
                    mem_write_addr <= '0;
                    mem_write_en <= '0;
                end
            end else begin
                mem_write_data <= '0;
                mem_write_en <= '0;
                mem_write_addr <= '0;
                next_mem_write_addr <= '0;
            end
        end
    end

    // Core reset while writing to program memory
    always_comb begin
        core_program_resetn = ~load_program;
    end

endmodule
