`timescale 1ns/1ps

module branch_history_table #(
    parameter unsigned BHT_N = 2,
    parameter unsigned BHT_TABLE_SIZE = 512
) (
    input logic clk,
    input logic rstn,

    // Query
    input logic [31:0] id_pc,
    output logic query_branch_taken,

    // Update
    input logic [31:0] ex_pc,
    input logic ex_branch_decision, // 0: Not taken, 1: Taken
    input logic ex_branch_update
);

    localparam unsigned TABLE_BITS = $clog2(BHT_TABLE_SIZE);

    logic [BHT_N-1:0] table[BHT_TABLE_SIZE];
    initial begin
        for (int i = 0; i < BHT_TABLE_SIZE; i++) begin
            table[i] <= '0;
        end
    end

    logic [TABLE_BITS-1:0] query_table_index, update_table_index;
    assign query_table_index  = id_pc[TABLE_BITS+1:2];   // Using 32-bit aligned PC
    assign update_table_index = ex_pc[TABLE_BITS+1:2];

    logic [BHT_N-1:0] query_table_entry, update_table_entry;
    assign query_table_entry  = table[query_table_index];
    assign update_table_entry = table[update_table_index];

    always_ff @(posedge clk) begin
        if (~rstn) begin
            for (int i = 0; i < BHT_TABLE_SIZE; i++) begin
                table[i] <= '0;
            end
        end else begin
            if (ex_branch_update) begin
                if (ex_branch_decision == 1'b1 && (update_table_entry != {BHT_N{1'b1}})) begin
                    table[update_table_index] <= update_table_entry + 1;
                end else if (ex_branch_decision == 1'b0 && (update_table_entry != {BHT_N{1'b0}})) begin
                    table[update_table_index] <= update_table_entry - 1;
                end
            end
        end
    end

    // Assign query output
    assign query_branch_taken = query_table_entry[BHT_N-1];

endmodule
