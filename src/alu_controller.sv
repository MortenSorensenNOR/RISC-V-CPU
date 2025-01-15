`timescale 1ns / 1ps

module alu_controller (
    // alu_op from main controller and func7 and funct3 from instruction
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    // Control signal to the ALU
    output logic [3:0] alu_ctrl
);

    // Some types for easier writing
    typedef enum logic [1:0] {
        LOAD_STORE_OP,
        BRANCHING_OP,
        ARITHMETIC_OP,
        ARITHMETIC_OP_IMMEDIATE
    } alu_op_decode_t;

    typedef enum logic [3:0] {
        ADD,
        SUB,
        XOR,
        OR,
        AND,
        SLL,
        SRL,
        SRA,
        NOP
    } alu_ctrl_type_t;

    // Decoding
    always_comb begin
        case (alu_op)
            LOAD_STORE_OP: begin
                alu_ctrl = ADD;
            end

            BRANCHING_OP: begin
                alu_ctrl = SUB;
            end

            ARITHMETIC_OP: begin
                case (funct3)
                    3'h0: begin
                        if (funct7 == 7'h00) begin
                            alu_ctrl = ADD;
                        end else if (funct7 == 7'h20) begin
                            alu_ctrl = SUB;
                        end else begin
                            alu_ctrl = NOP;
                        end
                    end

                    3'h4: begin
                        alu_ctrl = XOR;
                    end

                    3'h6: begin
                        alu_ctrl = OR;
                    end

                    3'h7: begin
                        alu_ctrl = AND;
                    end

                    3'h1: begin
                        alu_ctrl = SLL;
                    end

                    3'h5: begin
                        if (funct7 == 7'h00) begin
                            alu_ctrl = SRL;
                        end else if (funct7 == 7'h20) begin
                            alu_ctrl = SRA;
                        end else begin
                            alu_ctrl = NOP;
                        end
                    end

                    default: begin
                        alu_ctrl = NOP;
                    end
                endcase
            end

            ARITHMETIC_OP_IMMEDIATE: begin
                case (funct3)
                    3'h0: begin
                        alu_ctrl = ADD;
                    end

                    3'h4: begin
                        alu_ctrl = XOR;
                    end

                    3'h6: begin
                        alu_ctrl = OR;
                    end

                    3'h7: begin
                        alu_ctrl = AND;
                    end

                    3'h1: begin
                        alu_ctrl = SLL;
                    end

                    3'h5: begin
                        if (funct7 == 7'h00) begin
                            alu_ctrl = SRL;
                        end else if (funct7 == 7'h20) begin
                            alu_ctrl = SRA;
                        end else begin
                            alu_ctrl = NOP;
                        end
                    end

                    default: begin
                    end
                endcase
            end

            default: begin
                alu_ctrl = NOP;
            end
        endcase
    end

endmodule
