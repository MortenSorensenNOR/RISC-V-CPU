`timescale 1ns/1ps

module EX_MEM_Reg (
    input logic clk,
    input logic rstn,

    // Input data
    input logic [31:0] ex_pc,
    input logic [31:0] ex_pc_p4,
    input logic [4:0]  ex_rd,

    input logic [31:0] ex_alu_result,

    input logic ex_mem_read,
    input logic ex_mem_write,
    input logic [1:0] ex_mem_data_mask,
    input logic [31:0] ex_mem_write_data,

    input logic ex_reg_write,
    input logic [1:0] ex_reg_write_src,

    // debug
    input logic [31:0] ex_instr,

    // Output data
    output logic [31:0] ex_mem_pc,
    output logic [31:0] ex_mem_pc_p4,
    output logic [4:0]  ex_mem_rd,

    output logic [31:0] ex_mem_alu_result,  // Doubles as the address for MEM write

    output logic ex_mem_mem_read,
    output logic ex_mem_mem_write,
    output logic [1:0] ex_mem_mem_data_mask,
    output logic [31:0] ex_mem_mem_write_data,

    output logic ex_mem_reg_write,
    output logic [1:0] ex_mem_reg_write_src,

    // debug
    output logic [31:0] ex_mem_instr
);

    initial begin
        ex_mem_pc = '0;
        ex_mem_pc_p4 = '0;
        ex_mem_rd = '0;

        ex_mem_alu_result = '0;

        ex_mem_mem_read = '0;
        ex_mem_mem_write = '0;
        ex_mem_mem_data_mask = '0;
        ex_mem_mem_write_data = '0;

        ex_mem_reg_write = '0;
        ex_mem_reg_write_src = '0;

        // debug
        ex_mem_instr = '0;
    end

    always_ff @(posedge clk) begin
        if (~rstn) begin
            ex_mem_pc <= '0;
            ex_mem_pc_p4 <= '0;
            ex_mem_rd <= '0;

            ex_mem_alu_result <= '0;

            ex_mem_mem_read <= '0;
            ex_mem_mem_write <= '0;
            ex_mem_mem_data_mask <= '0;
            ex_mem_mem_write_data <= '0;

            ex_mem_reg_write <= '0;
            ex_mem_reg_write_src <= '0;

            // debug
            ex_mem_instr <= '0;
        end else begin
            ex_mem_pc <= ex_pc;
            ex_mem_pc_p4 <= ex_pc_p4;
            ex_mem_rd <= ex_rd;

            ex_mem_alu_result <= ex_alu_result;

            ex_mem_mem_read <= ex_mem_read;
            ex_mem_mem_write <= ex_mem_write;
            ex_mem_mem_data_mask <= ex_mem_data_mask;
            ex_mem_mem_write_data <= ex_mem_write_data;

            ex_mem_reg_write <= ex_reg_write;
            ex_mem_reg_write_src <= ex_reg_write_src;

            // debug
            ex_mem_instr <= ex_instr;
        end
    end

endmodule
