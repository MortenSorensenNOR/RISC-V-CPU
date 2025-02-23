`timescale 1ns/1ps

/* verilator lint_off UNUSED */
/* verilator lint_off LITENDIAN */
module d_mem #(
    parameter unsigned MEMORY_SIZE = 2048,   // Bytes
    parameter string DATA_FILE_PATH = ""
) (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    input logic [3:0]  data_mask,
    input logic write_en,
    input logic read_en,            // Unused for now

    output logic [31:0] read_data
);

    localparam int MEM_BLOCKS = MEMORY_SIZE/4;

    logic [0:31] d_mem[MEM_BLOCKS];
    logic [0:31] read_word;

    logic [31:0] addr_block;
    assign addr_block = {{2{1'b0}}, addr[31:2]};

    // Setup
    initial begin
        if (DATA_FILE_PATH != "") begin
            $readmemh(DATA_FILE_PATH, d_mem);
        end else begin
            for (int i = 0; i < MEM_BLOCKS; i++) begin
                d_mem[i] = '0;
            end
        end
    end

    // Write op
    always_ff @(posedge clk) begin
        for (int i = 0; i < 4; i++) begin
            if (write_en & (addr_block < MEM_BLOCKS) && data_mask[i]) begin
                d_mem[addr_block][8*i +: 8] <= write_data[8*i +: 8];
            end
        end
    end

    // Read -- For now, make it simple and read 32-bit
    always_comb begin
        read_word = d_mem[addr_block];

        case (data_mask)
            4'b0001: begin
                read_data = {{24{1'b0}}, read_word[8 * addr[1:0] +: 8]};
            end

            4'b0011: begin
                read_data = {
                    {16{1'b0}},
                    read_word[(8 * addr[1:0] + 8) +: 8],
                    read_word[(8 * addr[1:0])     +: 8]
                };
            end

            default: begin
                read_data = {read_word[24 +: 8], read_word[16 +: 8],
                             read_word[8  +: 8], read_word[0  +: 8]};
            end
        endcase
    end

endmodule
