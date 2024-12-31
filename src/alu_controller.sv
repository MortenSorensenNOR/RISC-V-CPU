`timescale 1ns / 1ps

module alu_controller (
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    output logic [3:0] alu_ctrl
);

    always_comb begin
        case (alu_op)
            2'b00: begin
                // Load/store, so always add
                alu_ctrl = 4'b0010;
            end

            2'b01: begin
                // Branch if equal, so always subtract
                alu_ctrl = 4'b0110;
            end

            2'b10: begin
                // TODO: Add more operations and make cleaner

                // R-Type instruction
                if (funct3 == 0) begin
                    if (funct7 == 0) begin
                        // Basic add operation
                        alu_ctrl = 4'b0010;
                    end else begin
                        // Basic sub operation
                        alu_ctrl = 4'b0110;
                    end
                end else begin
                    if (funct3 == 3'b111) begin
                        // AND operation
                        alu_ctrl = 4'b0000;
                    end else if (funct3 == 3'b110) begin
                        // OR operation
                        alu_ctrl = 4'b0001;
                    end else begin
                        // NOT IMPLEMENTED -- ERROR
                        alu_ctrl = 4'b1111;
                    end
                end
            end

            default: begin
                alu_ctrl = 15;
            end
        endcase
    end

endmodule
