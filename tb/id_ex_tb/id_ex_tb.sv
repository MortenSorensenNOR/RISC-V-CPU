`timescale 1ns/1ps

/* verilator lint_off UNUSED */
module id_ex_tb (
    input logic [31:0] pc,
    input logic [31:0] instr,

    // From "register file"
    input logic [31:0] rd1,
    input logic [31:0] rd2,

    output logic [31:0] AluResult,
    output logic AluZero,
    output logic AluOvf,
    output logic AluSign
);

    // ========== Immediate Generator ==========
    logic [31:0] w_id_imm;
    immediate_generator imm_gen_inst (
        .instruction(instr),
        .imm(w_id_imm)
    );

    // ========== Branch Target Adder ==========
    logic [31:0] w_id_branch_target;
    always_comb begin
        w_id_branch_target = $signed(pc) + $signed(w_id_imm);
    end

    // ========== Controller ==========
    logic [6:0] w_id_funct7;
    logic [2:0] w_id_funct3;
    logic [4:0] w_id_rd;
    logic [4:0] w_id_rs1, w_id_rs2;

    logic w_id_branch;
    logic w_id_jump;
    logic w_id_jump_src;

    logic [1:0] w_id_alu_op;
    logic [0:0] w_id_alu_src_a;
    logic [1:0] w_id_alu_src_b;

    logic w_id_mem_write;
    logic w_id_mem_read;

    logic w_id_reg_write;
    logic [1:0] w_id_reg_write_src;

    controller controller_inst (
        .instruction(instr),
        .funct7(w_id_funct7),
        .funct3(w_id_funct3),

        .rs1(w_id_rs1),
        .rs2(w_id_rs2),
        .rd(w_id_rd),

        .Branch(w_id_branch),
        .Jump(w_id_jump),
        .JumpSrc(w_id_jump_src),

        .alu_op(w_id_alu_op),
        .alu_src_a(w_id_alu_src_a),
        .alu_src_b(w_id_alu_src_b),

        .MemWrite(w_id_mem_write),
        .MemRead(w_id_mem_read),

        .RegWrite(w_id_reg_write),
        .RegWriteSrc(w_id_reg_write_src)
    );

    // ========== EX Stage ==========
    ex_stage ex_stage_inst (
        .alu_op(w_id_alu_op),
        .funct7(w_id_funct7),
        .funct3(w_id_funct3),

        .alu_src_a(w_id_alu_src_a),
        .alu_src_b(w_id_alu_src_b),

        .rd1(rd1),
        .rd2(rd2),
        .imm(w_id_imm),
        .branch_target(w_id_branch_target),

        .AluResult(AluResult),
        .AluZero(AluZero),
        .AluOvf(AluOvf),
        .AluSign(AluSign)
    );

endmodule;
