`timescale 1ns / 1ps

module alu_controller (
    // alu_op from main controller and func7 and funct3 from instruction
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    // Control signal to the ALU
    output logic [3:0] alu_ctrl,
    output logic [2:0] cmp_ctrl
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

    typedef enum logic [2:0] {
        EQ,
        NE,
        LT,
        GE,
        LTU,
        GEU
    } cmp_ctrl_type_t;

    // Decoding
    always_comb begin
        alu_ctrl = NOP;
        cmp_ctrl = '0;

        case (alu_op)
            LOAD_STORE_OP: begin
                alu_ctrl = ADD;
            end

            BRANCHING_OP: begin
                case (funct3)
                    3'h0: cmp_ctrl = EQ;
                    3'h1: cmp_ctrl = NE;
                    3'h4: cmp_ctrl = LT;
                    3'h5: cmp_ctrl = GE;
                    3'h6: cmp_ctrl = LTU;
                    3'h7: cmp_ctrl = GEU;

                    default: cmp_ctrl = '0;
                endcase
            end

            ARITHMETIC_OP: begin
                case (funct3)
                    3'h0: begin
                        case (funct7)
                            7'h00: alu_ctrl = ADD;
                            7'h20: alu_ctrl = SUB;
                            default: alu_ctrl = NOP;
                        endcase
                    end

                    3'h4: alu_ctrl = XOR;
                    3'h6: alu_ctrl = OR;
                    3'h7: alu_ctrl = AND;
                    3'h1: alu_ctrl = SLL;

                    3'h5: begin
                        case (funct7)
                            7'h00: alu_ctrl = SRL;
                            7'h20: alu_ctrl = SRA;
                            default: alu_ctrl = NOP;
                        endcase
                    end

                    3'h2: cmp_ctrl = LT;
                    3'h3: cmp_ctrl = LTU;
                    default: alu_ctrl = NOP;

                endcase
            end

            ARITHMETIC_OP_IMMEDIATE: begin
                case (funct3)
                    3'h0: alu_ctrl = ADD;
                    3'h4: alu_ctrl = XOR;
                    3'h6: alu_ctrl = OR;
                    3'h7: alu_ctrl = AND;
                    3'h1: alu_ctrl = SLL;
                    3'h5: begin
                        case (funct7)
                            7'h00: alu_ctrl = SRL;
                            7'h20: alu_ctrl = SRA;
                            default: alu_ctrl = NOP;
                        endcase
                    end

                    3'h2: cmp_ctrl = LT;
                    3'h3: cmp_ctrl = LTU;

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
