`timescale 1ns / 1ps

module alu (
    input  logic [3:0] alu_ctrl,

    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] alu_do,

    output logic zero,
    output logic ovf
);

    // Operations
    always_comb begin
        case (alu_ctrl)
            0: begin
                alu_do = A & B;
            end

            1: begin
                alu_do = A | B;
            end

            2: begin
                alu_do = $signed(A) + $signed(B);
            end

            6: begin
                alu_do = $signed(A) - $signed(B);
            end

            7: begin
                alu_do = $signed(A) < $signed(B) ? 1 : 0;
            end

            12: begin
                alu_do = ~(A | B);
            end

            default: begin
                alu_do = 0;
            end
        endcase
    end

    // Overflow detection
    always_comb begin
        case (alu_ctrl)
            2: begin
                ovf = (~A[31] & ~B[31] &  alu_do[31]) |
                      ( A[31] &  B[31] & ~alu_do[31]);
            end

            6: begin
                ovf = ( A[31] & ~B[31] & ~alu_do[31]) |
                      (~A[31] &  B[31] &  alu_do[31]);
            end

            default: begin
                ovf = 0;
            end
        endcase
    end

    assign zero = (alu_do == 0);
endmodule
