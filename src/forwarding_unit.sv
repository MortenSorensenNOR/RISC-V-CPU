`timescale 1ns/1ps

module forwarding_unit (
    input logic mem_reg_write,
    input logic [4:0] mem_rd,

    input logic wb_reg_write,
    input logic [4:0] wb_rd,

    input logic [4:0] ex_rs1,
    input logic [4:0] ex_rs2,

    // MUX signals for forwarding in EX stage
    output logic [1:0] ex_forward_alu_a,        // 00: rd1, 01: mem_wb_result, 10: ex_mem_alu_result
    output logic [1:0] ex_forward_alu_b         // 00: rd2, 01: mem_wb_result, 10: ex_mem_alu_result
);

    always_comb begin
        ex_forward_alu_a = '0;
        ex_forward_alu_b = '0;

        // Forwarding for port A of ALU
        if (mem_reg_write & (mem_rd == ex_rs1) & (mem_rd != '0)) begin
            ex_forward_alu_a = 2'b10;
        end else if (wb_reg_write & (wb_rd == ex_rs1) & (wb_rd != '0)) begin
            ex_forward_alu_a = 2'b01;
        end

        // Forwarding for port B of ALU
        if (mem_reg_write & (mem_rd == ex_rs2) & (mem_rd != '0)) begin
            ex_forward_alu_b = 2'b10;
        end else if (wb_reg_write & (wb_rd == ex_rs2) & (wb_rd != '0)) begin
            ex_forward_alu_b = 2'b01;
        end
    end

endmodule
