`timescale 1ns/1ps

module if_stage #(
    parameter unsigned CPU_RESET_VECTOR = 0     // Reset value for the PC, start of CPU execution
) (
    input logic clk,
    input logic rstn,

    input logic if_stall,

    // PC
    input logic PCNextSrc,              // 0: PC + 4, 1: PC+IMM/IMM+RS1
    input logic PCJumpTargetSrc,        // 0: PC+IMM, 1: IMM+RS1

    input logic [31:0] pc_plus_imm,
    input logic [31:0] pc_target_alu,

    output logic [31:0] if_pc,
    output logic [31:0] if_pc_p4,

    // Instruction fetching
    output logic [31:0] o_instr_mem_read_addr,
    input  logic [31:0] i_instr_mem_read_data,
    // TODO: Add ready valid handshake to memory read

    output logic [31:0] if_instr
);

    logic [31:0] PC;
    logic reset_last = 1'b0;    // Ensure that we do not increment
                                // before one clock after a reset

    // PC + 4
    logic [31:0] pc_p4;
    always_comb begin
        pc_p4 = PC + 32'd4;
    end

    // PC Next Logic
    logic [31:0] w_pc_next;
    always_comb begin
        if (PCNextSrc) begin
            if (PCJumpTargetSrc) begin
                w_pc_next = pc_target_alu;
            end else begin
                w_pc_next = pc_plus_imm;
            end
        end else begin
            w_pc_next = pc_p4;
        end
    end

    // Assign new PC
    always_ff @(posedge clk) begin
        if (~rstn) begin
            PC <= CPU_RESET_VECTOR;
            reset_last <= 1'b1;
        end else begin
            reset_last <= 1'b0;

            if (~reset_last && ~if_stall) begin
                PC <= w_pc_next;
            end
        end
    end

    // PC
    assign if_pc = PC;
    assign if_pc_p4 = pc_p4;

    // Instruction
    assign o_instr_mem_read_addr = if_pc;
    assign if_instr = i_instr_mem_read_data;

endmodule
