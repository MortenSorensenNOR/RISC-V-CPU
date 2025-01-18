`timescale 1ns/1ps

module ID_EX_Reg (
    input logic clk,
    input logic rstn,

    // Control
    input logic id_ex_flush,

    // Input
    input logic [31:0] id_pc,
    input logic [31:0] id_pc_p4,
    input logic [31:0] id_branch_target,

    input logic [6:0]  id_funct7,
    input logic [2:0]  id_funct3,

    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [4:0] id_rd,

    input logic [31:0] id_rd1,
    input logic [31:0] id_rd2,

    input logic id_branch,
    input logic id_jump,
    input logic id_jump_src,

    input logic [1:0] id_alu_op,
    input logic [0:0] id_alu_src_a,
    input logic [1:0] id_alu_src_b,

    input logic id_mem_write,
    input logic id_mem_read,

    input logic id_reg_write,
    input logic [1:0] id_reg_write_src,

    input logic [31:0] id_imm,

    // Debug
    input logic [31:0] id_instr,

    // Output
    output logic [31:0] id_ex_pc,
    output logic [31:0] id_ex_pc_p4,
    output logic [31:0] id_ex_branch_target,

    output logic [6:0]  id_ex_funct7,
    output logic [2:0]  id_ex_funct3,

    output logic [4:0] id_ex_rs1,
    output logic [4:0] id_ex_rs2,
    output logic [4:0] id_ex_rd,

    output logic [31:0] id_ex_rd1,
    output logic [31:0] id_ex_rd2,

    output logic id_ex_branch,
    output logic id_ex_jump,
    output logic id_ex_jump_src,

    output logic [1:0] id_ex_alu_op,
    output logic [0:0] id_ex_alu_src_a,
    output logic [1:0] id_ex_alu_src_b,

    output logic id_ex_mem_write,
    output logic id_ex_mem_read,

    output logic id_ex_reg_write,
    output logic [1:0] id_ex_reg_write_src,

    output logic [31:0] id_ex_imm,

    // Debug
    output logic [31:0] id_ex_instr
);

    initial begin
        id_ex_pc = '0;
        id_ex_pc_p4 = '0;
        id_ex_branch_target = '0;

        id_ex_funct7 = '0;
        id_ex_funct3 = '0;

        id_ex_rs1 = '0;
        id_ex_rs2 = '0;
        id_ex_rd = '0;

        id_ex_rd1 = '0;
        id_ex_rd2 = '0;

        id_ex_branch = '0;
        id_ex_jump = '0;
        id_ex_jump_src = '0;

        id_ex_alu_op = '0;
        id_ex_alu_src_a = '0;
        id_ex_alu_src_b = '0;

        id_ex_mem_write = '0;
        id_ex_mem_read = '0;

        id_ex_reg_write = '0;
        id_ex_reg_write_src = '0;

        id_ex_imm = '0;

        // Debug
        id_ex_instr = '0;
    end

    always_ff @(posedge clk) begin
        if (~rstn) begin
            id_ex_pc <= '0;
            id_ex_pc_p4 <= '0;
            id_ex_branch_target <= '0;

            id_ex_funct7 <= '0;
            id_ex_funct3 <= '0;

            id_ex_rs1 <= '0;
            id_ex_rs2 <= '0;
            id_ex_rd <= '0;

            id_ex_rd1 <= '0;
            id_ex_rd2 <= '0;

            id_ex_branch <= '0;
            id_ex_jump <= '0;
            id_ex_jump_src <= '0;

            id_ex_alu_op <= '0;
            id_ex_alu_src_a <= '0;
            id_ex_alu_src_b <= '0;

            id_ex_mem_write <= '0;
            id_ex_mem_read <= '0;

            id_ex_reg_write <= '0;
            id_ex_reg_write_src <= '0;

            id_ex_imm <= '0;

            // Debug
            id_ex_instr <= '0;
        end else begin
            if (id_ex_flush) begin
                id_ex_pc <= '0;
                id_ex_pc_p4 <= '0;
                id_ex_branch_target <= '0;

                id_ex_funct7 <= '0;
                id_ex_funct3 <= '0;

                id_ex_rs1 <= '0;
                id_ex_rs2 <= '0;
                id_ex_rd <= '0;

                id_ex_rd1 <= '0;
                id_ex_rd2 <= '0;

                id_ex_branch <= '0;
                id_ex_jump <= '0;
                id_ex_jump_src <= '0;

                id_ex_alu_op <= '0;
                id_ex_alu_src_a <= '0;
                id_ex_alu_src_b <= '0;

                id_ex_mem_write <= '0;
                id_ex_mem_read <= '0;

                id_ex_reg_write <= '0;
                id_ex_reg_write_src <= '0;

                id_ex_imm <= '0;

                // Debug
                id_ex_instr <= '0;
            end else begin
                id_ex_pc <= id_pc;
                id_ex_pc_p4 <= id_pc_p4;
                id_ex_branch_target <= id_branch_target;

                id_ex_funct7 <= id_funct7;
                id_ex_funct3 <= id_funct3;

                id_ex_rs1 <= id_rs1;
                id_ex_rs2 <= id_rs2;
                id_ex_rd <= id_rd;

                id_ex_rd1 <= id_rd1;
                id_ex_rd2 <= id_rd2;

                id_ex_branch <= id_branch;
                id_ex_jump <= id_jump;
                id_ex_jump_src <= id_jump_src;

                id_ex_alu_op <= id_alu_op;
                id_ex_alu_src_a <= id_alu_src_a;
                id_ex_alu_src_b <= id_alu_src_b;

                id_ex_mem_write <= id_mem_write;
                id_ex_mem_read <= id_mem_read;

                id_ex_reg_write <= id_reg_write;
                id_ex_reg_write_src <= id_reg_write_src;

                id_ex_imm <= id_imm;

                // Debug
                id_ex_instr <= id_instr;
            end
        end
    end

endmodule
