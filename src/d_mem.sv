`timescale 1ns/1ps

module d_mem #(
    parameter unsigned MEMORY_SIZE = 2048,   // Bytes
    parameter string DATA_FILE_PATH = ""
) (
    input logic clk,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    input logic [1:0]  data_mask,
    input logic write_en,
    input logic read_en,

    output logic [31:0] read_data
);

    logic [7:0] mem[MEMORY_SIZE];

    // Setup
    initial begin
        if (DATA_FILE_PATH != "") begin
            $readmemh(DATA_FILE_PATH, mem);
        end else begin
            for (int i = 0; i < MEMORY_SIZE; i++) begin
                mem[i] = '0;
            end
        end
    end

    // Write op
    always_ff @(posedge clk) begin
        if (write_en & (addr < MEMORY_SIZE)) begin
            case (data_mask)
                2'b01: begin
                    mem[addr] <= write_data[7:0];
                end

                2'b10: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end

                2'b11: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end

                default: begin
                end
            endcase
        end
    end

    // Read op
    always_comb begin
        read_data = '0;

        if (read_en & (addr < MEMORY_SIZE)) begin
            case (data_mask)
                2'b01: begin
                    read_data = {{24{1'b0}}, mem[addr]};
                end

                2'b10: begin
                    read_data = {{16{1'b0}}, mem[addr+1], mem[addr]};
                end

                2'b11: begin
                    read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                end

                default: begin
                end
            endcase
            $display("DATA:  Read (0x%04x): 0x%04x", addr, read_data);
        end
    end

endmodule
