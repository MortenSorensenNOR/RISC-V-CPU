`timescale 1ns/1ps

module branch_unit (
    input logic [2:0] funct3,
    input logic Branch,
    input logic Jump,

    // From ALU
    input logic AluZero,
    input logic AluSign,

    // Output mux select signal: (PC+Imm/rd1+Imm) or PC + 4
    output logic PCNextSrc
);

    always_comb begin
        PCNextSrc = 1'b0;

        if (Jump) begin
            // Jump instruction: always change PC
            PCNextSrc = 1'b1;
        end else if (Branch) begin
            case (funct3)
                3'h0: begin
                    // beq:     rd1 - rd2 = 0
                    if (AluZero == 1'b1) begin
                        PCNextSrc = 1'b1;
                    end
                end

                3'h1: begin
                    // bne:     rd1 - rd2 != 0
                    if (AluZero == 1'b0) begin
                        PCNextSrc = 1'b1;
                    end
                end

                3'h4: begin
                    // blt:     rd1 - rd2 < 0
                    if (AluSign == 1'b1) begin
                        PCNextSrc = 1'b1;
                    end
                end

                3'h5: begin
                    // bge:     rd1 - rd2 >= 0
                    if (AluSign == 1'b0 || AluZero == 1'b1) begin
                        PCNextSrc = 1'b1;
                    end
                end

                // TODO: Add bltu (0x6) and bgeu (0x7)

                default: begin
                    PCNextSrc = 1'b0;
                end
            endcase
        end
    end

endmodule
