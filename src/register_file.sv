`timescale 1ns / 1ps

module register_file (
    input logic clk,
    input logic rstn,

    input logic [4:0] RS1,
    input logic [4:0] RS2,
    input logic [4:0] RD,

    // Write stuff
    input logic RegWrite,
    input  logic [31:0] WriteData,

    // Read output data
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    // 32-bit Register declaration
    logic [31:0] regs [32];

    // For simulation only
    initial begin
        foreach (regs[i]) regs[i] = '0;
    end


    // Write data on negative edge
    /* verilator lint_off MULTIDRIVEN */
    genvar i;
    generate
        for (i = 0; i < 31; i++) begin : gen_register_file
            // Ensure x0 is 0
            always_ff @(posedge clk) begin
                if (~rstn) begin
                    regs[i] <= '0;
                end else begin
                    if (i == 0) begin : gen_reg_0_zero
                        regs[0] <= '0;
                    end else begin    : gen_reg_write
                        if (RegWrite && RD == i && i != 0) begin     // Cannot write to reg0, always "0"
                            regs[i] <= WriteData;
                    end
                end
            end
        end
    end
    endgenerate
    /* verilator lint_on MULTIDRIVEN */

    // Continually drive output data signals
    always_comb begin
        if (~rstn) begin
            RD1 = '0;
            RD2 = '0;
        end else begin
            RD1 = regs[RS1];
            RD2 = regs[RS2];
        end
    end

endmodule
