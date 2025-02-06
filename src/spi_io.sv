`timescale 1ns/1ps

/*
* SPI Module for communicating with external device. The spi module can
* transfer a 32-bit number as a series of 4 bytes. When the input memory bus
* addr equals the set address for the module, the module reads/writes to/from
* the memory bus. In the case of a write_en beign high, the spi module reads
* the value into a register and starts transferring the data that it reads
* over the external spi bus to the external device. If a read ensues, i.e. the
* read_en signal is high, the status of the spi_io module shall be placed on
* the memory bus in order to inform the cpu of the current status of the I/O
* unit. The following decoding may be used for the byte that is written to the
* memory bus (by bit of the first byte):
*   1.   Busy flag -- 1 if the device is busy with a transfer, 0 if ready for a new transfer
*   2-7: TBD
*/

module spi_io #(
    // Determines the clk rate for the SPI bus, derived from main system clk
    parameter unsigned CLKS_PER_HALF_BIT = 2,

    // Address of the SPI I/O module on the memory bus
    parameter unsigned SPI_IO_ADDR = 32'h80000000
) (
    input logic clk,
    input logic rstn,

    // Memory bus interface
    input  logic [31:0] mem_bus_addr,
    input  logic [31:0] mem_bus_data,
    input  logic        mem_bus_write_en,
    input  logic [1:0]  mem_bus_data_mask,

    input  logic        mem_bus_read_en,
    output logic [7:0]  mem_bus_spi_status,
    output logic        mem_bus_spi_status_write_en,    // SPI I/O allowed precedence over data mem

    output logic o_spi_sck,
    output logic o_spi_mosi,
    output logic o_spi_csn
);
    // Save data from mem bus
    logic       r_write_valid;
    logic [7:0] r_write_data[4];
    logic [1:0] r_write_data_mask;

    // Registers for SPI
    logic [2:0] r_spi_tx_count;
    logic [7:0] r_spi_tx_byte;
    logic       r_spi_tx_dv;
    logic       w_spi_tx_ready;

    spi_master #(
        .SPI_MODE(0),
        .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT),
        .MAX_BYTES_PER_CS(4),
        .CS_INACTIVE_CLKS(1)
    ) spi_master_inst (
        .clk(clk),
        .rstn(rstn),

        .i_TX_Count(r_spi_tx_count),
        .i_TX_Byte(r_spi_tx_byte),
        .i_TX_DV(r_spi_tx_dv),
        .o_TX_Ready(w_spi_tx_ready),

        .o_RX_Count(),
        .o_RX_DV(),
        .o_RX_Byte(),

        .o_SCK(o_spi_sck),
        .i_MISO(),
        .o_MOSI(o_spi_mosi),
        .o_CSn(o_spi_csn)
    );

endmodule
