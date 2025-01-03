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
    output logic [31:0] RS1_DO,
    output logic [31:0] RS2_DO
);

    // 32-bit Register declaration
    logic [31:0] regs [32];

    // For simulation only
    initial begin
        foreach (regs[i]) regs[i] <= '0;
    end

    // Write data on negative edge
    always_ff @(negedge clk or negedge rstn) begin
        if (~rstn) begin
            foreach (regs[i]) regs[i] <= '0;
        end else begin
            if (RegWrite) begin
                regs[RD] <= WriteData;
            end
        end
    end

    // Continually drive output data signals
    always_comb begin
        if (~rstn) begin
            RS1_DO = '0;
            RS2_DO = '0;
        end else begin
            RS1_DO = regs[RS1];
            RS2_DO = regs[RS2];
        end
    end

endmodule
