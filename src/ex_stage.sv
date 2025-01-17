`timescale 1ns/1ps

module ex_stage (
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    input logic [0:0] alu_src_a,
    input logic [1:0] alu_src_b,

    input logic branch,
    input logic jump,

    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [31:0] rd1,
    input logic [31:0] rd2,
    input logic [31:0] imm,
    input logic [31:0] branch_target,

    input logic mem_reg_write,
    input logic [4:0] mem_rd,
    input logic wb_reg_write,
    input logic [4:0] wb_rd,

    input logic [31:0] mem_forward_value,
    input logic [31:0] wb_forward_value,

    output logic [31:0] AluResult,
    output logic AluZero,
    output logic AluOvf,
    output logic AluSign,

    output logic PCNextSrc,

    output logic [31:0] MemWriteData
);

    // ========== ALU Controller ==========
    logic [3:0] alu_ctrl;

    alu_controller alu_controller_inst (
        .alu_op(alu_op),
        .funct7(funct7),
        .funct3(funct3),
        .alu_ctrl(alu_ctrl)
    );

    // ========== ALU Controller ==========
    logic [1:0] forward_alu_a, forward_alu_b;

    forwarding_unit forwarding_unit_inst (
        .mem_reg_write(mem_reg_write),
        .mem_rd(mem_rd),

        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),

        .ex_rs1(rs1),
        .ex_rs2(rs2),

        .ex_forward_alu_a(forward_alu_a),
        .ex_forward_alu_b(forward_alu_b)
    );

    // ========== ALU Src A ==========
    logic [31:0] rd1_forwarded;
    logic [31:0] A;

    always_comb begin
        case (forward_alu_a)
            2'b00: begin
                rd1_forwarded = rd1;
            end

            2'b01: begin
                rd1_forwarded = wb_forward_value;
            end

            2'b10: begin
                rd1_forwarded = mem_forward_value;
            end

            default: begin
                rd1_forwarded = '0;
            end
        endcase

        case (alu_src_a)
            1'b0: begin
                A = rd1_forwarded;
            end

            default: begin
                A = '0;
            end
        endcase
    end

    // ========== ALU Src B ==========
    logic [31:0] rd2_forwarded;
    logic [31:0] B;

    always_comb begin
        case (forward_alu_b)
            2'b00: begin
                rd2_forwarded = rd2;
            end

            2'b01: begin
                rd2_forwarded = wb_forward_value;
            end

            2'b10: begin
                rd2_forwarded = mem_forward_value;
            end

            default: begin
                rd2_forwarded = '0;
            end
        endcase

        case (alu_src_b)
            2'b00: begin
                B = rd2_forwarded;
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

    // ========== Branch logic ==========
    branch_unit branch_unit_inst (
        .funct3(funct3),
        .Branch(branch),
        .Jump(jump),

        .AluZero(w_alu_zero),
        .AluSign(w_alu_do[31]),

        .PCNextSrc(PCNextSrc)
    );

    assign AluResult = w_alu_do;
    assign AluZero = w_alu_zero;
    assign AluOvf = w_alu_ovf;
    assign AluSign = w_alu_do[31];

    assign MemWriteData = rd2_forwarded;

endmodule
