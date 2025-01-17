`timescale 1ns/1ps

module IF_ID_Reg (
    input logic clk,
    input logic rstn,

    input logic if_id_stall,
    input logic if_id_flush,

    input logic [31:0] if_pc,
    input logic [31:0] if_pc_p4,
    input logic [31:0] if_instr,

    output logic [31:0] if_id_pc,
    output logic [31:0] if_id_pc_p4,
    output logic [31:0] if_id_instr
);

    initial begin
        if_id_pc = '0;
        if_id_pc_p4 = '0;
        if_id_instr = '0;
    end

    always_ff @(posedge clk) begin
        if (~rstn) begin
            if_id_pc <= '0;
            if_id_pc_p4 <= '0;
            if_id_instr <= '0;
        end else begin
            if (~if_id_stall) begin
                if (if_id_flush) begin
                    if_id_pc <= '0;
                    if_id_pc_p4 <= '0;
                    if_id_instr <= '0;
                end else begin
                    if_id_pc <= if_pc;
                    if_id_pc_p4 <= if_pc_p4;
                    if_id_instr <= if_instr;
                end
            end
        end
    end

endmodule
