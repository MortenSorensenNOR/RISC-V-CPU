`timescale 1ns/1ps

module ex_stage (
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    input logic [0:0] alu_src_a,
    input logic [1:0] alu_src_b,

    input logic [31:0] rd1,
    input logic [31:0] rd2,
    input logic [31:0] imm,
    input logic [31:0] branch_target,

    output logic [31:0] AluResult,
    output logic AluZero,
    output logic AluOvf,
    output logic AluSign
);

    // ========== ALU Controller ==========
    logic [3:0] alu_ctrl;

    alu_controller alu_controller_inst (
        .alu_op(alu_op),
        .funct7(funct7),
        .funct3(funct3),
        .alu_ctrl(alu_ctrl)
    );

    // ========== ALU Src A ==========
    logic [31:0] A;

    always_comb begin
        case (alu_src_a)
            1'b0: begin
                A = rd1;
            end

            default: begin
                A = '0;
            end
        endcase
    end

    // ========== ALU Src B ==========
    logic [31:0] B;

    always_comb begin
        case (alu_src_b)
            2'b00: begin
                B = rd2;
            end

            2'b01: begin
                B = imm;
            end

            2'b10: begin
                B = branch_target;
            end

            default: begin
                B = '0;
            end
        endcase
    end

    // ========== ALU ==========
    logic [31:0] w_alu_do;
    logic w_alu_zero, w_alu_ovf;

    alu alu_inst (
        .alu_ctrl(alu_ctrl),

        .A(A),
        .B(B),
        .alu_do(w_alu_do),

        .zero(w_alu_zero),
        .ovf(w_alu_ovf)
    );

    assign AluResult = w_alu_do;
    assign AluZero = w_alu_zero;
    assign AluOvf = w_alu_ovf;
    assign AluSign = w_alu_do[31];

endmodule
