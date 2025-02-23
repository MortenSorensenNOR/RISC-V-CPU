`timescale 1ns / 1ps

module alu (
    input  logic [3:0] alu_ctrl,
    input  logic [2:0] cmp_ctrl,

    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] alu_do,
    output logic cmp_result
);

    // ========== ARITHMETIC ==========
    // alu_ctrl encoding
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

    // Operations
    logic [31:0] alu_sum, alu_sub, alu_xor, alu_or, alu_and, alu_sll, alu_srl, alu_sra;

    always_comb begin
        alu_sum = $signed(A) + $signed(B);
        alu_sub = $signed(A) - $signed(B);
        alu_xor = A ^ B;
        alu_or  = A | B;
        alu_and = A & B;
        alu_sll = A << B[4:0];
        alu_srl = A >> B[4:0];
        alu_sra = $signed(A) >>> B[4:0];
    end


    always_comb begin
        alu_do = '0;

        case (alu_ctrl)
            ADD: alu_do = alu_sum;
            SUB: alu_do = alu_sub;
            XOR: alu_do = alu_xor;
            OR:  alu_do = alu_or;
            AND: alu_do = alu_and;
            SLL: alu_do = alu_sll;
            SRL: alu_do = alu_srl;
            SRA: alu_do = alu_sra;
            default: alu_do = '0;
        endcase
    end

    // Overflow detection: See earlier commit, i.e. 95937484d0095e6b388ba9d16e48756ff24799a1

    // ========== COMPARISON ==========
    typedef enum logic [2:0] {
        eq,
        neq,
        lt,
        ge,
        ltu,
        geu
    } cmp_ctrl_type_t;

    logic cmp_is_equal;
    logic cmp_is_less_sign;
    logic cmp_is_less_unsign;

    always_comb begin
        cmp_is_equal       = (A == B);
        cmp_is_less_sign   = $signed(A) < $signed(B);
        cmp_is_less_unsign = $unsigned(A) < $unsigned(B);
    end

    // Determine cmp_result
    always_comb begin
        cmp_result = 1'b0;

        case (cmp_ctrl)
            eq:  cmp_result =  cmp_is_equal;
            neq: cmp_result = ~cmp_is_equal;
            lt:  cmp_result =  cmp_is_less_sign;
            ge:  cmp_result = ~cmp_is_less_sign;
            ltu: cmp_result =  cmp_is_less_unsign;
            geu: cmp_result = ~cmp_is_less_unsign;

            default: begin
                cmp_result = 1'b0;
            end
        endcase
    end

endmodule
