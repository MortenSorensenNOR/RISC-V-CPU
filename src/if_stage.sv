`timescale 1ns/1ps

module if_stage #(
    parameter unsigned CPU_RESET_VECTOR = 0     // Reset value for the PC, start of CPU execution
) (
    input logic clk,
    input logic rstn,

    input logic if_stall,

    // PC
    input logic BranchPredictTaken,             // From ID Branch predictor
    input logic EXPcJumpTaken,                  // Branch taken in EX
    input logic EXPcJumpSource,                 // Alu result or branch target as ex branch target
    input logic PcRestore,                      // Restore PC to PC + 4 if an inncorrect
                                                // branch prediction has taken place

    // From ID
    input logic [31:0] id_branch_target,

    // From EX
    input logic [31:0] ex_branch_target,
    input logic [31:0] ex_branch_target_alu,
    input logic [31:0] ex_branch_restore_pc_p4,

    // Output to next stage
    output logic [31:0] if_pc,
    output logic [31:0] if_pc_p4,

    // Instruction fetching
    output logic [31:0] o_instr_mem_read_addr,
    input  logic [31:0] i_instr_mem_read_data,
    // TODO: Add ready valid handshake to memory read

    output logic [31:0] if_instr
);

    logic [31:0] PC;
    logic [31:0] pc_p4;
    logic reset_last = 1'b0;

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

            if (~if_stall && ~reset_last) begin
                PC <= w_pc_next;
            end
        end
    end

    // PC + 4
    always_comb begin
        pc_p4 = PC + 32'd4;
    end

    // PC
    assign if_pc = PC;
    assign if_pc_p4 = pc_p4;

    // Instruction
    assign o_instr_mem_read_addr = if_pc;
    assign if_instr = i_instr_mem_read_data;

endmodule
