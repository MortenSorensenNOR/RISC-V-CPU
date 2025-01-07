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
        foreach (regs[i]) regs[i] <= '0;
    end

    // Write data on negative edge
    always_ff @(negedge clk or negedge rstn) begin
        if (~rstn) begin
            foreach (regs[i]) regs[i] <= '0;
        end else begin
            if (RegWrite && RD != '0) begin     // Cannot write to reg0, always "0"
                regs[RD] <= WriteData;
            end
        end
    end

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
