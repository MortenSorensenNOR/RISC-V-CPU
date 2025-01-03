`timescale 1ns / 1ps

module alu (
    input  logic [3:0] alu_ctrl,

    input  logic [31:0] A,
    input  logic [31:0] B,
    output logic [31:0] alu_do,

    output logic zero,
    output logic ovf
);

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
endmodule
