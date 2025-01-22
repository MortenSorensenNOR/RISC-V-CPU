`timescale 1ns/1ps

/*
* SPI I/O Unit
*/

module spi_io_unit #(
    parameter unsigned SPI_MODE = 0,                        // Mode for operation
    parameter unsigned SPI_TARGET_FREQ = 1_000_000,         // Output SCK freq (Hz)
    parameter unsigned SPI_INPUT_CLK_FREQ = 100_000_000     // Input clk freq (Hz)
) (
    input logic clk,
    input logic rstn,

    // Host memory bus interface
    input logic [31:0] mem_bus_addr,

    // Device wants to write data to device memory -- Will be used to load
    // program into host
    input  logic device_write_req,      // device requests to write to host

    // SPI interface
    output logic host_MOSI,
    input  logic host_MISO,
    output logic host_SCK,
    output logic host_CSn
);

    // Localparams
    localparam unsigned SPI_CLK_OVERDRIVE = (SPI_INPUT_CLK_FREQ / SPI_TARGET_FREQ) / 2;

    // Host -> Device
    // For now, host will only write to a single memory addr on the device.
    // TODO: Add addressing for Host to Device writes
    logic host_to_device_write_en;
    logic [31:0] host_to_device_write_data;

    logic [31:0] host_to_device_read_addr;
    logic [31:0] device_to_host_read_data;

    // Device -> Host
    logic [31:0] device_to_host_write_addr;
    logic [31:0] device_to_host_write_data;

    // State machine
    typedef enum logic [2:0] {
        IDLE,
    } state_t;

endmodule
