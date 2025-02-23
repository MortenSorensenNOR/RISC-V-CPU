`timescale 1ns / 1ps

module controller (
    input logic [31:0] instruction,
    output logic [6:0] funct7,
    output logic [2:0] funct3,

    // Registers
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,

    // PC
    output logic Branch,    // For branching
    output logic Jump,      // For jal
    output logic JumpSrc,   // 0 for jal, 1 for jalr

    // EX
    output logic [1:0] alu_op,
    output logic [0:0] alu_src_a,   // 0:  RD1, 1:  "0"
    output logic [1:0] alu_src_b,   // 00: RD2, 01: Imm, 10: Imm + PC

    // MEM
    output logic MemWrite,
    output logic MemRead,
    output logic [3:0] MemDataMask, // 01: byte, 10: half word, 11: word
    output logic MemReadSignExtend,

    // WB
    output logic RegWrite,
    output logic [1:0] RegWriteSrc // 00: alu_res, 01: MemRead, 10: PC + 4
);
    // Some types for easier writing
    typedef enum logic [1:0] {
        LOAD_STORE_OP,
        BRANCHING_OP,
        ARITHMETIC_OP,
        ARITHMETIC_OP_IMMEDIATE
    } alu_op_decode_t;

    // Segmenting the opcode, funct7 and funct3 for convenience
    logic [6:0] opcode; // Local reference only
    assign opcode = instruction[6:0];
    assign funct7 = instruction[31:25];
    assign funct3 = instruction[14:12];

    // Also for source and destination registers
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // Determine the rest of the control signals
    always_comb begin
        // Make sure no latches are created
        Branch = 1'b0;
        Jump = 1'b0;
        JumpSrc = 1'b0;

        alu_op = 2'b00;
        alu_src_a = 1'b0;
        alu_src_b = 2'b00;

        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemDataMask = 4'b1111;
        MemReadSignExtend = 1'b1;
        RegWrite = 1'b0;
        RegWriteSrc = 2'b00;

        case (opcode)
            7'b0110011: begin
                // Arithmetic operation
                RegWrite = 1'b1;
                RegWriteSrc = 2'b00;
                alu_op = ARITHMETIC_OP;
                alu_src_a = 1'b0;
                alu_src_b = 2'b00;
            end

            7'b0010011: begin
                // Arithmetic Immedate
                RegWrite = 1'b1;
                RegWriteSrc = 2'b00;
                alu_op = ARITHMETIC_OP_IMMEDIATE;
                alu_src_a = 1'b0;
                alu_src_b = 2'b01;
            end

            7'b0000011: begin
                // Load
                MemRead = 1'b1; // Might remove, is usefull for real system
                RegWrite = 1'b1;
                MemReadSignExtend = 1'b1;

                // Load mask
                case (funct3)
                    3'h0: begin
                        MemDataMask = 4'b0001;
                    end

                    3'h4: begin
                        MemDataMask = 4'b0001;
                        MemReadSignExtend = 1'b0;
                    end

                    3'h1: begin
                        MemDataMask = 4'b0011;
                    end

                    3'h5: begin
                        MemDataMask = 4'b0011;
                        MemReadSignExtend = 1'b0;
                    end

                    3'h2: begin
                        MemDataMask = 4'b1111;
                    end

                    default: begin
                        MemDataMask = 4'b1111;
                    end
                endcase

                RegWriteSrc = 2'b01;
                alu_op = LOAD_STORE_OP;
                alu_src_a = 1'b0;
                alu_src_b = 2'b01;
            end

            7'b0100011: begin
                // Store
                MemWrite = 1'b1;

                // Load mask
                case (funct3)
                    3'h0, 3'h4: begin
                        MemDataMask = 4'b0001;
                    end

                    3'h1, 3'h5: begin
                        MemDataMask = 4'b0011;
                    end

                    3'h2: begin
                        MemDataMask = 4'b1111;
                    end

                    default: begin
                        MemDataMask = 4'b1111;
                    end
                endcase

                alu_op = LOAD_STORE_OP;
                alu_src_a = 1'b0;
                alu_src_b = 2'b01;
            end

            7'b1100011: begin
                // Branch
                Branch = 1'b1;
                JumpSrc = 1'b0;
                alu_op = BRANCHING_OP;
                alu_src_a = 1'b0;
                alu_src_b = 2'b00;
            end

            7'b1101111: begin
                // Jump, PC + imm   (jal)
                // Does not use the ALU, uses seperate adder for now
                Jump = 1'b1;
                JumpSrc = 1'b0;
                RegWrite = 1'b1;
                RegWriteSrc = 2'b10;
            end

            7'b1100111: begin
                // Jump with rs1 + imm  (jalr)
                // Therefore use ARITHMETIC_OP_IMMEDIATE
                Jump = 1'b1;
                JumpSrc = 1'b1;

                alu_op  = ARITHMETIC_OP_IMMEDIATE;
                alu_src_a = 1'b0;
                alu_src_b = 2'b01;

                RegWrite = 1'b1;
                RegWriteSrc = 2'b10;
            end

            7'b0110111: begin
                // Load upper immediate
                // Do an add of 0 + imm
                // Because no funct3, we need to use forced add,
                // i.e. by using LOAD_STORE_OP which always doens an add
                RegWrite = 1'b1;
                RegWriteSrc = 2'b00;
                alu_op = LOAD_STORE_OP;
                alu_src_a = 1'b1;   // "0"
                alu_src_b = 2'b01;  // Imm
            end

            7'b0010111: begin
                // auipc
                RegWrite = 1'b1;
                RegWriteSrc = 2'b00;
                alu_op = LOAD_STORE_OP;
                alu_src_a = 1'b1;
                alu_src_b = 2'b10; // PC + Imm
            end

            default: begin
                Branch = 1'b0;
                Jump = 1'b0;
                JumpSrc = 1'b0;

                alu_op = 2'b00;
                alu_src_a = 1'b0;
                alu_src_b = 2'b00;

                MemRead  = 1'b0;
                MemWrite = 1'b0;
                RegWrite = 1'b0;
                RegWriteSrc = 2'b00;
            end
        endcase
    end

endmodule
