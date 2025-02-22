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

/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */

module spi_io #(
    // Determines the clk rate for the SPI bus, derived from main system clk
    parameter unsigned CLKS_PER_HALF_BIT = 5,

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
    output logic [7:0]  mem_bus_spi_status,             // Bit meanings, see above
    output logic        mem_bus_spi_status_write_en,    // SPI I/O allowed precedence over data mem

    output logic o_spi_sck,
    output logic o_spi_mosi,
    output logic o_spi_csn
);

    // Save data from mem bus
    logic [7:0] r_write_data[4];

    // Registers for SPI
    logic [2:0] r_spi_tx_num_bytes;
    logic [1:0] r_spi_tx_count;
    logic [7:0] r_spi_tx_byte;
    logic       r_spi_tx_dv;
    logic       w_spi_tx_ready;

    logic w_spi_done;

    /* verilator lint_off PINCONNECTEMPTY */
    spi_master #(
        .SPI_MODE(0),
        .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT),
        .MAX_BYTES_PER_CS(4),
        .CS_INACTIVE_CLKS(1)
    ) spi_master_inst (
        .clk(clk),
        .rstn(rstn),

        .i_TX_Count(r_spi_tx_num_bytes),
        .i_TX_Byte(r_spi_tx_byte),
        .i_TX_DV(r_spi_tx_dv),
        .o_TX_Ready(w_spi_tx_ready),
        .o_done(w_spi_done),

        .o_RX_Count(),
        .o_RX_DV(),
        .o_RX_Byte(),

        .o_SCK(o_spi_sck),
        .i_MISO(),
        .o_MOSI(o_spi_mosi),
        .o_CSn(o_spi_csn)
    );

    // SPI I/O
    logic busy;

    // State
    typedef enum logic [2:0] {
        IDLE,
        WRITING,
        DONE
    } state_t;

    state_t current_state = IDLE;
    state_t next_state;

    always_ff @(posedge clk) begin
        if (~rstn) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;
        busy = 1;

        case (current_state)
            IDLE: begin
                if (w_spi_tx_ready) begin
                    if (mem_bus_addr == SPI_IO_ADDR && mem_bus_write_en) begin
                        next_state = WRITING;
                    end

                    busy = 0;
                end
            end

            WRITING: begin
                if (w_spi_done) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (~rstn) begin
            r_spi_tx_num_bytes <= '0;
            r_spi_tx_count <= '0;
            r_spi_tx_byte <= '0;
            r_spi_tx_dv <= 1'b0;

            foreach(r_write_data[i]) r_write_data[i] <= '0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (w_spi_tx_ready) begin
                        if (mem_bus_addr == SPI_IO_ADDR && mem_bus_write_en) begin
                            r_write_data[0] <= mem_bus_data[7:0];
                            r_write_data[1] <= mem_bus_data[15:8];
                            r_write_data[2] <= mem_bus_data[23:16];
                            r_write_data[3] <= mem_bus_data[31:24];

                            case (mem_bus_data_mask)
                                2'b01: begin
                                    r_spi_tx_num_bytes <= 3'b001;
                                end

                                2'b10: begin
                                    r_spi_tx_num_bytes <= 3'b010;
                                end

                                2'b11: begin
                                    r_spi_tx_num_bytes <= 3'b100;
                                end

                                default: begin
                                    r_spi_tx_num_bytes <= '0;
                                end
                            endcase
                        end
                    end
                    r_spi_tx_count <= '0;
                    r_spi_tx_byte <= '0;
                    r_spi_tx_dv <= 1'b0;
                end

                WRITING: begin
                    if (w_spi_tx_ready && !w_spi_done) begin
                        r_spi_tx_byte <= r_write_data[r_spi_tx_count];
                        r_spi_tx_count <= r_spi_tx_count + 1;
                        r_spi_tx_dv <= 1'b1;
                    end else begin
                        r_spi_tx_dv <= 1'b0;
                    end
                end

                DONE: begin
                    r_spi_tx_dv <= 1'b0;
                end

                default: begin
                    r_spi_tx_dv <= 1'b0;
                end
            endcase
        end
    end

    // Status stuff
    always_comb begin
        if (mem_bus_addr == SPI_IO_ADDR && mem_bus_read_en) begin
            mem_bus_spi_status_write_en = 1'b1;
        end else begin
            mem_bus_spi_status_write_en = 1'b0;
        end
        mem_bus_spi_status = {{7{1'b0}}, busy};
    end



endmodule
