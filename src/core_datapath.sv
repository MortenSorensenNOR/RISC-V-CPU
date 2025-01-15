`timescale 1ns/1ps

module core_datapath (
    input logic clk,
    input logic rstn
);
    // IF
    logic if_pc_next_src, if_pc_jump_target_src;
    logic [31:0] if_pc_pluss_imm, if_target_alu;
    logic [31:0] if_pc, if_pc_p4;
    logic [31:0] if_instr;

    // IF-ID
    logic if_id_stall, if_id_flush;
    logic [31:0] if_id_pc, if_id_pc_p4, if_id_instr;

    // WB-ID
    logic wb_reg_write;
    logic [4:0] wb_reg_write_rd;
    logic [31:0] wb_reg_write_data;

    // ID
    logic [6:0] id_funct7;
    logic [2:0] id_funct3;
    logic [4:0] id_rs1, id_rs2, id_rd;
    logic [31:0] id_rd1, id_rd2;
    logic id_branch, id_jump, id_jump_src;
    logic [1:0] id_alu_op, id_alu_src_b;
    logic [0:0] id_alu_src_a;
    logic id_mem_write, id_mem_read;
    logic id_reg_write;
    logic [1:0] id_reg_write;
    logic [31:0] id_imm, id_branch_target;

    // ID-EX
    logic id_ex_flush;

    logic [31:0] id_ex_pc, id_ex_pc_p4, id_ex_branch_target;
    logic [6:0] id_ex_funct7;
    logic [2:0] id_ex_funct3;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [31:0] id_ex_rd1, id_ex_rd2;
    logic id_ex_branch, id_ex_jump;
    logic [1:0] id_ex_alu_op;
    logic [0:0] id_ex_alu_src_a;
    logic [1:0] id_ex_alu_src_b;
    logic id_ex_mem_write, id_ex_mem_read;
    logic id_ex_reg_write;
    logic [1:0] id_ex_reg_write_src;
    logic [31:0] id_ex_imm;

    // ========== INSTRUCTION FETCH STAGE ==========
    if_stage if_stage_inst (
        .clk(clk),
        .rstn(rstn),

        // PC
        .PCNextSrc,
        .PCJumpTargetSrc,

        .pc_plus_imm,
        .pc_target_alu,

        .if_pc,
        .if_pc_p4,

        // Instruction fetching
        .o_instr_mem_read_addr,
        .i_instr_mem_read_data,

        .if_instr
    );

    // ========== IF-ID Regs ==========
    IF_ID_Reg if_id_reg_inst (
        .clk(clk),
        .rstn(rstn),

        .if_id_stall(if_id_stall),
        .if_id_flush(if_id_flush),

        .if_pc(if_pc),
        .if_pc_p4(if_pc_p4),
        .if_instr(if_instr),

        .if_id_pc(if_id_pc),
        .if_id_pc_p4(if_id_pc_p4),
        .if_id_instr(if_id_instr)
    );

    // ========== INSTRUCTION DECODE STAGE ==========
    id_stage id_stage_inst (
        .clk,
        .rstn,

        // From IF
        .if_instr(if_instr),
        .if_pc(if_pc),

        // From WB
        .wb_reg_write(wb_reg_write),
        .wb_reg_write_rd(wb_reg_write_rd),
        .wb_reg_write_data(wb_reg_write_data),

        // ID Output
        .id_funct7(id_funct7),
        .id_funct3(id_funct3),

        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),

        .id_rd1(id_rd1),
        .id_rd2(id_rd2),

        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_jump_src(id_jump_src),

        .id_alu_op(id_alu_op),
        .id_alu_src_a(id_alu_src_a),
        .id_alu_src_b(id_alu_src_b),

        .id_mem_write(id_mem_write),
        .id_mem_read(id_mem_read),

        .id_reg_write(id_reg_write),
        .id_reg_write_src(id_reg_write_src),

        .id_imm(id_imm),
        .id_branch_target(id_branch_target)
    );

    // ========== ID-EX Regs ==========
    ID_EX_Reg id_ex_reg_inst (
        .clk(clk),
        .rstn(rstn),

        // Control
        .id_ex_flush(id_ex_flush),

        // Input
        .id_pc(id_pc),
        .id_pc_p4(id_pc_p4),
        .id_branch_target(id_branch_target),

        .id_funct7(id_funct7),
        .id_funct3(id_funct3),

        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),

        .id_rd1(id_rd1),
        .id_rd2(id_rd2),

        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_jump_src(id_jump_src),

        .id_alu_op(id_alu_op),
        .id_alu_src_a(id_alu_src_a),
        .id_alu_src_b(id_alu_src_b),

        .id_mem_write(id_mem_write),
        .id_mem_read(id_mem_read),

        .id_reg_write(id_reg_write),
        .id_reg_write_src(id_reg_write_src),

        .id_imm(id_imm),

        // Output
        .id_ex_pc(id_ex_pc),
        .id_ex_pc_p4(id_ex_pc_p4),
        .id_ex_branch_target(id_ex_branch_target),

        .id_ex_funct7(id_ex_funct7),
        .id_ex_funct3(id_ex_funct3),

        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rd(id_ex_rd),

        .id_ex_rd1(id_ex_rd1),
        .id_ex_rd2(id_ex_rd2),

        .id_ex_branch(id_ex_branch),
        .id_ex_jump(id_ex_jump),
        .id_ex_jump_src(id_ex_jump_src),

        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_alu_src_a(id_ex_alu_src_a),
        .id_ex_alu_src_b(id_ex_alu_src_b),

        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_mem_read(id_ex_mem_read),

        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_reg_write_src(id_ex_reg_write_src),

        .id_ex_imm(id_ex_imm)
    );

    // ========== EX STAGE ==========
    ex_stage ex_stage_inst (

    );

    // ========== EX-MEM Regs ==========
    EX_MEM_Reg ex_mem_reg_inst (
        
    );

    // ========== LOAD STORE STAGE ==========
    load_store_stage load_store_stage_inst (

    );

    // ========== MEM-WB Regs ==========
    MEM_WB_Reg mem_wb_reg_inst (
        
    );

    // ========== WB STAGE ==========
    wb_stage wb_stage_inst (

    );

endmodule
