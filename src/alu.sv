`timescale 1ns / 1ps

module alu (
    input  logic [3:0] alu_ctrl,
    input  logic [2:0] cmp_ctrl,

    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] alu_do,
    output logic cmp_result,

    output logic zero,
    output logic ovf
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
    always_comb begin
        alu_do = '0;

        case (alu_ctrl)
            ADD: begin
                alu_do = $signed(A) + $signed(B);
            end

            SUB: begin
                alu_do = $signed(A) - $signed(B);
            end

            XOR: begin
                alu_do = A ^ B;
            end

            OR: begin
                alu_do = A | B;
            end

            AND: begin
                alu_do = A & B;
            end

            // For shift operations only the lower 5 bits are used
            SLL: begin
                alu_do = A << B[4:0];
            end

            SRL: begin
                alu_do = A >> B[4:0];
            end

            SRA: begin
                alu_do = $signed(A) >>> B[4:0];
            end

            default: begin
                alu_do = '0;
            end
        endcase
    end


    // Overflow detection
    always_comb begin
        case (alu_ctrl)
            ADD: begin
                // Addition
                ovf = (~A[31] & ~B[31] &  alu_do[31]) |
                      ( A[31] &  B[31] & ~alu_do[31]);
            end

            SUB: begin
                // Subtraction
                ovf = ( A[31] & ~B[31] & ~alu_do[31]) |
                      (~A[31] &  B[31] &  alu_do[31]);
            end

            default: begin
                ovf = 0;
            end
        endcase
    end

    assign zero = (alu_do == 0);

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
