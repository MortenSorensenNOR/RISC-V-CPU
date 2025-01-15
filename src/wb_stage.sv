`timescale 1ns/1ps

module wb_stage (
    input logic WB_RegWrite,
    input logic [4:0] WB_RD,
    input logic [1:0] RegWriteSrc,

    input logic [31:0] AluResult,
    input logic [31:0] ReadData,
    input logic [31:0] PCPlus4,

    output logic ID_RegWrite,
    output logic [31:0] ID_RegWriteData,
    output logic [4:0]  ID_RD
);

    always_comb begin
        if (WB_RegWrite) begin
            ID_RegWrite = 1'b1;
            ID_RD = WB_RD;

            case (RegWriteSrc)
                2'b00: begin
                    // ALU Result
                    ID_RegWriteData = AluResult;
                end

                2'b01: begin
                    // Memory Read Data
                    ID_RegWriteData = ReadData;
                end

                2'b10: begin
                    // PC + 4
                    ID_RegWriteData = PCPlus4;
                end

                default: begin
                    // Something wrong has happened
                    ID_RegWrite = 1'b0;
                    ID_RegWriteData = '0;
                end
            endcase

        end else begin
            ID_RegWrite = 1'b0;
            ID_RegWriteData = '0;
            ID_RD = '0;
        end
    end

endmodule
