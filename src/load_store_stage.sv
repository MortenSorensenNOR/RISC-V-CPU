`timescale 1ns/1ps

module load_store_stage (
    // Input from EX/MEM
    input logic [31:0] DataAddr,
    input logic [31:0] WriteData,
    input logic WriteEnable,
    input logic ReadEnable,
    input logic [1:0] DataMask,
    input logic SignExtend,

    // Output to MEM/WB
    output logic [31:0] ReadData,

    // External signals
    output logic [31:0] o_data_mem_addr,
    output logic [31:0] o_data_mem_write_data,
    output logic o_data_mem_read_en,
    output logic o_data_mem_write_en,
    output logic [1:0] o_data_mem_data_mask,
    input logic  [31:0] i_data_mem_read_data
);

    // In here there will eventually be logic for handeling sw, sh, and sb
    // (and equivelent load instructions), but for now it will simply not do
    // much and just pass the signals to the data memeory

    assign o_data_mem_addr = DataAddr;
    assign o_data_mem_write_data = WriteData;
    assign o_data_mem_read_en = ReadEnable;
    assign o_data_mem_write_en = WriteEnable;
    assign o_data_mem_data_mask = DataMask;

    // Do sign extention
    always_comb begin
        ReadData = '0;

        case (DataMask)
            2'b01: begin
                if (SignExtend) begin
                    ReadData = {{24{i_data_mem_read_data[7]}}, i_data_mem_read_data[7:0]};
                end else begin
                    ReadData = {24'h000000, i_data_mem_read_data[7:0]};
                end
            end

            2'b10: begin
                if (SignExtend) begin
                    ReadData = {{16{i_data_mem_read_data[15]}}, i_data_mem_read_data[15:0]};
                end else begin
                    ReadData = {16'h0000, i_data_mem_read_data[15:0]};
                end
            end

            2'b11: begin
                ReadData = i_data_mem_read_data;
            end

            default: begin
            end
        endcase
    end

    assign ReadData = i_data_mem_read_data;

endmodule
