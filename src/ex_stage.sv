`timescale 1ns/1ps

module ex_stage (
    input logic [1:0] alu_op,
    input logic [6:0] funct7,
    input logic [2:0] funct3,

    input logic [0:0] alu_src_a,
    input logic [1:0] alu_src_b,

    input logic branch,
    input logic jump,

    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [31:0] rd1,
    input logic [31:0] rd2,
    input logic [31:0] imm,
    input logic [31:0] branch_target,

    input logic mem_reg_write,
    input logic [4:0] mem_rd,
    input logic wb_reg_write,
    input logic [4:0] wb_rd,

    input logic [31:0] mem_forward_value,
    input logic [31:0] wb_forward_value,

    output logic [31:0] AluResult,
    output logic BranchDecision,

    output logic [31:0] MemWriteData
);
    typedef enum logic [1:0] {
        LOAD_STORE_OP,
        BRANCHING_OP,
        ARITHMETIC_OP,
        ARITHMETIC_OP_IMMEDIATE
    } alu_op_decode_t;

    // ========== ALU Controller ==========
    logic [3:0] alu_ctrl;
    logic [2:0] cmp_ctrl;

    alu_controller alu_controller_inst (
        .alu_op(alu_op),
        .funct7(funct7),
        .funct3(funct3),
        .alu_ctrl(alu_ctrl),
        .cmp_ctrl(cmp_ctrl)
    );

    // ========== ALU Controller ==========
    logic [1:0] forward_alu_a, forward_alu_b;

    forwarding_unit forwarding_unit_inst (
        .mem_reg_write(mem_reg_write),
        .mem_rd(mem_rd),

        .wb_reg_write(wb_reg_write),
        .wb_rd(wb_rd),

        .ex_rs1(rs1),
        .ex_rs2(rs2),

        .ex_forward_alu_a(forward_alu_a),
        .ex_forward_alu_b(forward_alu_b)
    );

    // ========== ALU Src A ==========
    logic [31:0] rd1_forwarded;
    logic [31:0] A;

    always_comb begin
        case (forward_alu_a)
            2'b00: rd1_forwarded = rd1;
            2'b01: rd1_forwarded = wb_forward_value;
            2'b10: rd1_forwarded = mem_forward_value;

            default: begin
                rd1_forwarded = '0;
            end
        endcase

        case (alu_src_a)
            1'b0: A = rd1_forwarded;

            default: begin
                A = '0;
            end
        endcase
    end

    // ========== ALU Src B ==========
    logic [31:0] rd2_forwarded;
    logic [31:0] B;

    always_comb begin
        case (forward_alu_b)
            2'b00: rd2_forwarded = rd2;
            2'b01: rd2_forwarded = wb_forward_value;
            2'b10: rd2_forwarded = mem_forward_value;

            default: begin
                rd2_forwarded = '0;
            end
        endcase

        case (alu_src_b)
            2'b00: B = rd2_forwarded;
            2'b01: B = imm;
            2'b10: B = branch_target;

            default: begin
                B = '0;
            end
        endcase
    end

    // ========== ALU ==========
    logic [31:0] w_alu_do;
    logic w_alu_cmp_result;

    alu alu_inst (
        .alu_ctrl(alu_ctrl),
        .cmp_ctrl(cmp_ctrl),

        .A(A),
        .B(B),
        .alu_do(w_alu_do),
        .cmp_result(w_alu_cmp_result)
    );

    // ========== Branch logic ==========
    logic w_branch_decision;
    always_comb begin
        w_branch_decision = jump | (branch & w_alu_cmp_result);
    end
    assign BranchDecision = w_branch_decision;

    // ========== Output Mux ==========
    always_comb begin
        case (alu_op)
            ARITHMETIC_OP, ARITHMETIC_OP_IMMEDIATE: begin
                case (funct3)
                    3'h2, 3'h3: begin
                        // slt, sltu, slti, sltiu
                        AluResult = {31'b0, w_alu_cmp_result};
                    end

                    default: begin
                        AluResult = w_alu_do;
                    end
                endcase
            end

            default: begin
                AluResult = w_alu_do;
            end
        endcase
    end

    assign AluResult = w_alu_do;
    assign MemWriteData = rd2_forwarded;

endmodule
