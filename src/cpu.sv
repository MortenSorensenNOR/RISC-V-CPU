`timescale 1ns / 1ps

module cpu (
    input logic clk,
    input logic rstn
);
    // Program counter
    logic [31:0] pc;

    // Instruction fetch

    // Instruction decode
    logic [6:0] w_id_opcode;
    logic [6:0] w_id_funct7;
    logic [2:0] w_id_funct3;

    logic [4:0] w_id_rs1;
    logic [4:0] w_id_rs2;
    logic [4:0] w_id_rd;

    // Controll unit

    // Immedate generation

    // Register file declaration
    logic [4:0] r_rf_rs1;
    logic [4:0] r_rf_rs2;
    logic [4:0] r_rf_rd;

    logic r_rf_reg_write;
    logic [31:0] r_rf_write_data;

    logic [31:0] w_rf_rs1_do;
    logic [31:0] w_rf_rs2_do;

    register_file reg_file_inst (
        .clk(clk),
        .rstn(rstn),

        .RS1(r_rf_rs1),
        .RS2(r_rf_rs2),
        .RD(r_rf_rd),

        .RegWrite(r_rf_reg_write),
        .WriteData(r_rf_write_data),

        .RS1_DO(w_rf_rs1_do),
        .RS2_DO(w_rf_rs2_do)
    );

    // ALU Declaration
    logic [3:0] w_alu_ctrl;

    logic [31:0] r_alu_A;
    logic [31:0] r_alu_B;
    logic [31:0] w_alu_do;

    logic w_alu_zero;
    logic w_alu_ovf;

    alu alu_inst (
        .alu_ctrl(w_alu_ctrl),

        .A(r_alu_A),
        .B(r_alu_B),
        .alu_do(r_alu_do),

        .zero(w_alu_zero),
        .ovf(w_alu_ovf)
    );

    // ALU Controller Declaration
    alu_controller alu_controller_inst (
        .alu_op(),
        .funct7(),
        .funct3(),

        .alu_ctrl(w_alu_ctrl)
    );

    // Forwarding unit

    // Branch target adder

    // Data memory

endmodule;
