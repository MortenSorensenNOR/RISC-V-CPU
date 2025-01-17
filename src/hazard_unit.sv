`timescale 1ns / 1ps

module hazard_unit (
    input logic BranchExecuted,
    input logic [4:0] ex_rd,
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    input logic [1:0] ex_reg_write_src,

    output logic if_stall,
    output logic id_stall,
    output logic id_flush,
    output logic ex_flush
);

    // Load-Use stall -- If we are going to write back the read data and one
    //                   of the alu sources is equal to this wb rd, stall the
    //                   following instruction when in the ex stage
    logic lu_stall;

    assign lu_stall = (ex_reg_write_src == 2'b01) & ((ex_rd == id_rs1) | (ex_rd == id_rs2));
    assign if_stall = lu_stall;
    assign id_stall = lu_stall;

    // Flush when branch is taken
    assign id_flush = BranchExecuted;
    assign ex_flush = BranchExecuted | lu_stall;

endmodule
