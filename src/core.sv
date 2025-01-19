`timescale 1ns/1ps

/* verilator lint_off UNUSED */
module core (
    input logic clk,
    input logic rstn,

    // IF
    output logic [31:0] o_instr_mem_read_addr,
    input logic [31:0] i_instr_mem_read_data,

    // MEM
    output logic [31:0] o_data_mem_addr,
    output logic [31:0] o_data_mem_write_data,
    output logic o_data_mem_read_en,
    output logic o_data_mem_write_en,
    output logic [1:0] o_data_mem_data_mask,
    input logic  [31:0] i_data_mem_read_data
);
    // IF
    logic if_stall;
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
    logic [1:0] id_mem_data_mask;
    logic id_reg_write;
    logic [1:0] id_reg_write_src;
    logic [31:0] id_imm, id_branch_target;

    // ID-EX
    logic id_ex_flush;

    logic [31:0] id_ex_pc, id_ex_pc_p4, id_ex_branch_target;
    logic [6:0] id_ex_funct7;
    logic [2:0] id_ex_funct3;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [31:0] id_ex_rd1, id_ex_rd2;
    logic id_ex_branch, id_ex_jump, id_ex_jump_src;
    logic [1:0] id_ex_alu_op;
    logic [0:0] id_ex_alu_src_a;
    logic [1:0] id_ex_alu_src_b;
    logic id_ex_mem_write, id_ex_mem_read;
    logic [1:0] id_ex_mem_data_mask;
    logic id_ex_reg_write;
    logic [1:0] id_ex_reg_write_src;
    logic [31:0] id_ex_imm;

    // debug
    logic [31:0] id_ex_instr;

    // EX
    logic [31:0] ex_alu_result;
    logic ex_alu_zero;
    logic ex_alu_ovf;
    logic ex_alu_sign;
    logic ex_pc_next_src;
    logic [31:0] ex_mem_write_data;

    // EX-Load/Store
    logic [31:0] ex_mem_pc;
    logic [31:0] ex_mem_pc_p4;
    logic [4:0]  ex_mem_rd;
    logic [31:0] ex_mem_alu_result;  // Doubles as the address for MEM write
    logic ex_mem_mem_write, ex_mem_mem_read;
    logic [1:0] ex_mem_mem_data_mask;
    logic [31:0] ex_mem_mem_write_data;
    logic ex_mem_reg_write;
    logic [1:0] ex_mem_reg_write_src;

    // debug
    logic [31:0] ex_mem_instr;

    // MEM
    logic [31:0] mem_read_data;

    // MEM-WB
    logic [31:0] mem_wb_pc;
    logic [31:0] mem_wb_pc_p4;
    logic [4:0]  mem_wb_rd;
    logic [31:0] mem_wb_alu_result;
    logic [31:0] mem_wb_mem_read_data;
    logic mem_wb_reg_write;
    logic [1:0] mem_wb_reg_write_src;

    // debug
    logic [31:0] mem_wb_instr;

    // ========== INSTRUCTION FETCH STAGE ==========
    if_stage if_stage_inst (
        .clk(clk),
        .rstn(rstn),

        .if_stall(if_stall),

        // PC
        .PCNextSrc(if_pc_next_src),
        .PCJumpTargetSrc(if_pc_jump_target_src),

        .pc_plus_imm(if_pc_pluss_imm),
        .pc_target_alu(if_target_alu),

        .if_pc(if_pc),
        .if_pc_p4(if_pc_p4),

        // Instruction fetching
        .o_instr_mem_read_addr(o_instr_mem_read_addr),
        .i_instr_mem_read_data(i_instr_mem_read_data),

        .if_instr(if_instr)
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
        .if_instr(if_id_instr),
        .if_pc(if_id_pc),

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
        .id_mem_data_mask(id_mem_data_mask),

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
        .id_pc(if_id_pc),
        .id_pc_p4(if_id_pc_p4),
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
        .id_mem_data_mask(id_mem_data_mask),

        .id_reg_write(id_reg_write),
        .id_reg_write_src(id_reg_write_src),

        .id_imm(id_imm),

        // debug
        .id_instr(if_id_instr),

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
        .id_ex_mem_data_mask(id_ex_mem_data_mask),

        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_reg_write_src(id_ex_reg_write_src),

        .id_ex_imm(id_ex_imm),

        // debug
        .id_ex_instr(id_ex_instr)
    );

    // ========== EX STAGE ==========
    ex_stage ex_stage_inst (
        .alu_op(id_ex_alu_op),
        .funct7(id_ex_funct7),
        .funct3(id_ex_funct3),

        .alu_src_a(id_ex_alu_src_a),
        .alu_src_b(id_ex_alu_src_b),

        .branch(id_ex_branch),
        .jump(id_ex_jump),

        .rs1(id_ex_rs1),
        .rs2(id_ex_rs2),
        .rd1(id_ex_rd1),
        .rd2(id_ex_rd2),
        .imm(id_ex_imm),
        .branch_target(id_ex_branch_target),

        .mem_reg_write(ex_mem_reg_write),
        .mem_rd(ex_mem_rd),
        .wb_reg_write(mem_wb_reg_write),
        .wb_rd(mem_wb_rd),

        .mem_forward_value(ex_mem_alu_result),
        .wb_forward_value(wb_reg_write_data),

        .AluResult(ex_alu_result),
        .AluZero(ex_alu_zero),
        .AluOvf(ex_alu_ovf),
        .AluSign(ex_alu_sign),

        .PCNextSrc(ex_pc_next_src),

        .MemWriteData(ex_mem_write_data)
    );

    // ========== EX-MEM Regs ==========
    EX_MEM_Reg ex_mem_reg_inst (
        .clk(clk),
        .rstn(rstn),

        .ex_pc(id_ex_pc),
        .ex_pc_p4(id_ex_pc_p4),
        .ex_rd(id_ex_rd),
        .ex_alu_result(ex_alu_result),
        .ex_mem_read(id_ex_mem_read),
        .ex_mem_write(id_ex_mem_write),
        .ex_mem_data_mask(id_ex_mem_data_mask),
        .ex_mem_write_data(ex_mem_write_data),
        .ex_reg_write(id_ex_reg_write),
        .ex_reg_write_src(id_ex_reg_write_src),

        // debug
        .ex_instr(id_ex_instr),

        .ex_mem_pc(ex_mem_pc),
        .ex_mem_pc_p4(ex_mem_pc_p4),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_mem_read(ex_mem_mem_read),
        .ex_mem_mem_write(ex_mem_mem_write),
        .ex_mem_mem_data_mask(ex_mem_mem_data_mask),
        .ex_mem_mem_write_data(ex_mem_mem_write_data),
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_reg_write_src(ex_mem_reg_write_src),

        // debug
        .ex_mem_instr(ex_mem_instr)
    );

    // ========== LOAD STORE STAGE ==========
    load_store_stage load_store_stage_inst (
        .DataAddr(ex_mem_alu_result),
        .WriteData(ex_mem_mem_write_data),
        .WriteEnable(ex_mem_mem_write),
        .ReadEnable(ex_mem_mem_read),
        .DataMask(ex_mem_mem_data_mask),
        .ReadData(mem_read_data),

        // External signals
        .o_data_mem_addr(o_data_mem_addr),
        .o_data_mem_write_data(o_data_mem_write_data),
        .o_data_mem_read_en(o_data_mem_read_en),
        .o_data_mem_write_en(o_data_mem_write_en),
        .o_data_mem_data_mask(o_data_mem_data_mask),
        .i_data_mem_read_data(i_data_mem_read_data)
    );

    // ========== MEM-WB Regs ==========
    MEM_WB_Reg mem_wb_reg_inst (
        .clk(clk),
        .rstn(rstn),

        .mem_pc(ex_mem_pc),
        .mem_pc_p4(ex_mem_pc_p4),
        .mem_rd(ex_mem_rd),
        .mem_alu_result(ex_mem_alu_result),
        .mem_mem_read_data(mem_read_data),
        .mem_reg_write(ex_mem_reg_write),
        .mem_reg_write_src(ex_mem_reg_write_src),

        // debug
        .mem_instr(ex_mem_instr),

        .mem_wb_pc(mem_wb_pc),
        .mem_wb_pc_p4(mem_wb_pc_p4),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_mem_read_data(mem_wb_mem_read_data),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_reg_write_src(mem_wb_reg_write_src),

        // debug
        .mem_wb_instr(mem_wb_instr)
    );

    // ========== WB STAGE ==========
    wb_stage wb_stage_inst (
        .WB_RegWrite(mem_wb_reg_write),
        .WB_RD(mem_wb_rd),
        .RegWriteSrc(mem_wb_reg_write_src),

        .AluResult(mem_wb_alu_result),
        .ReadData(mem_wb_mem_read_data),
        .PCPlus4(mem_wb_pc_p4),

        .ID_RegWrite(wb_reg_write),
        .ID_RegWriteData(wb_reg_write_data),
        .ID_RD(wb_reg_write_rd)
    );

    // ========== Hazards ==========
    hazard_unit hazard_unit_inst (
        .BranchExecuted(ex_pc_next_src),
        .ex_rd(id_ex_rd),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .ex_reg_write_src(id_ex_reg_write_src),

        .if_stall(if_stall),
        .id_stall(if_id_stall),
        .id_flush(if_id_flush),
        .ex_flush(id_ex_flush)

    );

    // EX-IF Signals
    assign if_pc_pluss_imm = id_ex_branch_target;
    assign if_target_alu   = ex_alu_result;

    // TODO: Make Hazard detection unit as well as implement branch
    assign if_pc_next_src = ex_pc_next_src;         // Decided by branch_unit
    assign if_pc_jump_target_src = id_ex_jump_src;  // Decided in ID

endmodule
