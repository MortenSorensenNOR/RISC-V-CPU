`timescale 1ns/1ps

module id_stage (
    input logic clk,
    input logic rstn,

    // From IF
    input logic [31:0] if_instr,
    input logic [31:0] if_pc,

    // From WB
    input logic wb_reg_write,
    input logic [4:0] wb_reg_write_rd,
    input logic [31:0] wb_reg_write_data,

    // ID Output
    output logic [6:0] id_funct7,
    output logic [2:0] id_funct3,

    output logic [4:0] id_rs1,
    output logic [4:0] id_rs2,
    output logic [4:0] id_rd,

    output logic [31:0] id_rd1,
    output logic [31:0] id_rd2,

    output logic id_branch,
    output logic id_jump,
    output logic id_jump_src,

    output logic [1:0] id_alu_op,
    output logic [0:0] id_alu_src_a,
    output logic [1:0] id_alu_src_b,

    output logic id_mem_write,
    output logic id_mem_read,

    output logic id_reg_write,
    output logic [1:0] id_reg_write_src,

    output logic [31:0] id_imm,
    output logic [31:0] id_branch_target
);

    // ========== Register File ==========
    logic [4:0] w_id_rs1, w_id_rs2;
    logic [31:0] w_id_rd1, w_id_rd2;  // Data read from register file using rs1, rs2

    register_file reg_file_inst (
        .clk(clk),
        .rstn(rstn),

        .RS1(w_id_rs1),
        .RS2(w_id_rs2),
        .RD(wb_reg_write_rd),

        .RegWrite(wb_reg_write),
        .WriteData(wb_reg_write_data),

        .RD1(w_id_rd1),
        .RD2(w_id_rd2)
    );

    // ========== Immediate Generator ==========
    logic [31:0] w_id_imm;

    immediate_generator imm_gen_inst (
        .instruction(if_instr),
        .imm(w_id_imm)
    );

    // ========== Controller ==========
    logic [6:0] w_id_funct7;
    logic [2:0] w_id_funct3;
    logic [4:0] w_id_rd;    // This instructions rd register

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
        .instruction(if_instr),
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

    // ========== Branch Target Adder ==========
    logic [31:0] w_id_branch_target;

    always_comb begin
        w_id_branch_target = $signed(if_pc) + $signed(w_id_imm);
    end

    // Assigns
    assign id_funct7 = w_id_funct7;
    assign id_funct3 = w_id_funct3;

    assign id_rs1 = w_id_rs1;
    assign id_rs2 = w_id_rs2;
    assign id_rd = w_id_rd;

    assign id_rd1 = w_id_rd1;
    assign id_rd2 = w_id_rd2;

    assign id_branch = w_id_branch;
    assign id_jump = w_id_jump;
    assign id_jump_src = w_id_jump_src;

    assign id_alu_op = w_id_alu_op;
    assign id_alu_src_a = w_id_alu_src_a;
    assign id_alu_src_b = w_id_alu_src_b;

    assign id_mem_write = w_id_mem_write;
    assign id_mem_read = w_id_mem_read;

    assign id_reg_write = w_id_reg_write;
    assign id_reg_write_src = w_id_reg_write_src;

    assign id_imm = w_id_imm;
    assign id_branch_target = w_id_branch_target;

endmodule
