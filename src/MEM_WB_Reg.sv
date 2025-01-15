`timescale 1ns/1ps

module MEM_WB_Reg (
    input logic clk,
    input logic rstn,

    // Input data
    input logic [31:0] mem_pc_p4,
    input logic [4:0]  mem_rd,

    input logic [31:0] mem_alu_result,
    input logic [31:0] mem_mem_read_data,

    input logic mem_reg_write,
    input logic [1:0] mem_reg_write_src,

    // Output data
    output logic [31:0] mem_wb_pc_p4,
    output logic [4:0]  mem_wb_rd,

    input logic [31:0] mem_wb_alu_result,
    output logic [31:0] mem_wb_mem_read_data,

    output logic mem_wb_reg_write,
    output logic [1:0] mem_wb_reg_write_src
);

    initial begin
        mem_wb_pc_p4 <= '0;
        mem_wb_rd <= '0;

        mem_alu_result <= '0;
        mem_wb_mem_read_data <= '0;

        mem_wb_reg_write <= '0;
        mem_wb_reg_write_src <= '0;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            mem_wb_pc_p4 <= '0;
            mem_wb_rd <= '0;

            mem_wb_alu_result <= '0;
            mem_wb_mem_read_data <= '0;

            mem_wb_reg_write <= '0;
            mem_wb_reg_write_src <= '0;
        end else begin
            mem_wb_pc_p4 <= mem_pc_p4;
            mem_wb_rd <= mem_rd;

            mem_wb_alu_result <= mem_alu_result;
            mem_wb_mem_read_data <= mem_mem_read_data;

            mem_wb_reg_write <= mem_reg_write;
            mem_wb_reg_write_src <= mem_reg_write_src;
        end
    end

endmodule
