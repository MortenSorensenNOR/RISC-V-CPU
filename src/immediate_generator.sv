`timescale 1ns/1ps

module immediate_generator (
    input logic [31:0] instruction,
    output logic [31:0] imm
);

    always_comb begin
        imm = '0;

        case (instruction[6:0])
            7'b0010011, 7'b0000011, 7'b1100111, 7'b1110011: begin
                // Sign extend, I-Type
                // Arithmetic Immediate, Load, jalr, Enviorment stuff
                imm = {{(20){instruction[31]}}, instruction[31:20]};
            end

            7'b0100011: begin
                // Sign extend, S-Type
                // Store
                imm = {{(20){instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            7'b1100011: begin
                // Sign extend, B-Type
                // Branch
                imm = {{(19){instruction[31]}}, instruction[31], instruction[7],
                                                instruction[30:25], instruction[11:8], 1'b0};

                // This follows as the endcoding from imm[12|10:5] from
                // instruction[31:25] and imm[4:1|11] from instruction[11:7] from the
                // B-Type instruciton format
            end

            7'b1101111: begin
                // Sign extend, J-Type
                // jal
                imm = {{(11){instruction[31]}}, instruction[31], instruction[19:12],
                                                instruction[20], instruction[30:21], 1'b0};

                // This follows as the endcoding imm[20|10:1|11|19:12] from
                // instruction[31:12]
            end

            7'b0110111, 7'b0010111: begin
                // U-Type
                // lui, auipc
                imm = {instruction[31:12], 12'b000000000000};
            end

            default: begin
                imm = '0;
            end
        endcase
    end

endmodule
