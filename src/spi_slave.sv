`timescale 1ns/1ps

/*
* SPI Slave Module:
* [+] Read RX Data
* [-] Write TX Data
* [+] SPI Mode 0
* [+] MSB Read First
*/

/* verilator lint_off UNUSED */
module spi_slave #(
    parameter unsigned SPI_MODE = 0
) (
    input logic clk,
    input logic rstn,

    output logic [7:0] RX_Byte,
    output logic RX_Valid,

    // input logic [7:0] TX_Byte,
    // input logic TX_Valid,
    // output logic TX_Ready,

    input logic MOSI,
    output logic MISO,
    input logic SCK,
    input logic CSn
);

    // Read from input buss
    logic [2:0] r_RX_Bit_Count;
    logic [7:0] r_Intermediate_RX_Byte;
    logic [7:0] r_RX_Byte;
    logic r_RX_Done;
    always_ff @(posedge SCK) begin
        if (CSn) begin
            r_RX_Bit_Count <= '0;
            r_RX_Done <= '0;
        end else begin
            r_RX_Bit_Count <= r_RX_Bit_Count + 3'b001;
            r_Intermediate_RX_Byte <= {r_Intermediate_RX_Byte[6:0], MOSI};

            if (r_RX_Bit_Count == 3'b111) begin
                r_RX_Done <= 1'b1;
                r_RX_Byte <= {r_Intermediate_RX_Byte[6:0], MOSI};
            end else begin
                r_RX_Done <= 1'b0;
            end
        end
    end

    // CDC
    logic [1:0] r_RX_Done_Sync;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            r_RX_Done_Sync[0] <= 1'b0;
            r_RX_Done_Sync[1] <= 1'b0;
            RX_Byte <= '0;
            RX_Valid <= '0;
        end else begin
            r_RX_Done_Sync[0] <= r_RX_Done;
            r_RX_Done_Sync[1] <= r_RX_Done_Sync[0];

            if (r_RX_Done_Sync[1] == 1'b0 && r_RX_Done_Sync[0] == 1'b1) begin
                RX_Valid <= 1'b1;
                RX_Byte <= r_RX_Byte;
            end else begin
                RX_Valid <= 1'b0;
            end
        end
    end

    // TODO: Implement TX
    assign MISO = '0;
endmodule
