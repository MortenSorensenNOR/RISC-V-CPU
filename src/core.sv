`timescale 1ns / 1ps

module core (
    input logic clk,
    input logic rstn
);
    // ======= Instruction fetch =======
    // Program counter
    logic [31:0] r_pc;
    logic [31:0] w_instruction;

    // Hazard Stall
    logic w_if_stall;

    // ======= IF-ID Register =======
    // Hazard stall/ branch flush
    logic w_id_stall;
    logic w_id_flush;

    logic [31:0] r_if_id_pc;
    logic [31:0] r_if_id_pc_p4;         // PC + 4 -> next instruction
    logic [31:0] r_if_id_instruction;

    // ======= WB-ID Signals =======
    logic w_wb_id_reg_write;
    logic [31:0] w_wb_id_reg_write_data;
    logic [4:0]  w_wb_id_rd;

    // ======= Instruction decode =======
    logic [6:0] w_id_opcode;
    logic [6:0] w_id_funct7;
    logic [2:0] w_id_funct3;

    // Register Source/Dest
    logic [4:0] w_id_rs1;
    logic [4:0] w_id_rs2;
    logic [4:0] w_id_rd;

    // PC Control Word
    logic w_id_branch;
    logic w_id_jump;
    logic w_id_jump_src;

    // EX Control Word
    logic [1:0] w_id_alu_op;
    logic [0:0] w_id_alu_src_a;
    logic [1:0] w_id_alu_src_b;

    // MEM Control Word
    logic w_id_mem_write;
    logic w_id_mem_read;

    // WB Control Word
    logic w_id_reg_write;
    logic [1:0] w_id_reg_write_src;

    // Controll unit
    controller controller_inst (
        .instruction(r_if_id_instruction),
        .opcode(w_id_opcode),
        .funct7(w_id_funct7),
        .funct3(w_id_funct3),

        .rs1(w_id_rs1),
        .rs2(w_id_rs2),
        .rd(w_id_rd),

        .Branch(w_id_branch),
        .Jump(w_id_jump),
        .JumpSrc(w_id_jump_src),

        .alu_op(w_id_alu_op),
        .alu_src_a(w_id_alu_src_a),
        .alu_src_b(w_id_alu_src_b),

        .MemWrite(w_id_mem_write),
        .MemRead(w_id_mem_read),

        .RegWrite(w_id_reg_write),
        .RegWrite_Src(w_id_reg_write_src)
    );

    // Immedate generation
    logic [31:0] w_id_imm;
    immediate_generator imm_gen_inst (
        .instruction(r_if_id_instruction),
        .imm(w_id_imm)
    );

    // Register file declaration
    logic [31:0] w_id_rd1;
    logic [31:0] w_id_rd2;

    register_file reg_file_inst (
        .clk(clk),
        .rstn(rstn),

        .RS1(w_id_rs1),
        .RS2(w_id_rs2),
        .RD(w_wb_id_rd),

        .RegWrite(w_wb_id_reg_write),
        .WriteData(w_wb_id_reg_write_data),

        .RD1(w_id_rd1),
        .RD2(w_id_rd2)
    );

    // ======= ID-EX Register =======
    // Branch flush
    logic w_ex_flush;

    // Control Words
    logic [6:0] r_id_ex_funct7;
    logic [2:0] r_id_ex_funct3;

    logic [4:0] r_id_ex_rs1;
    logic [4:0] r_id_ex_rs2;
    logic [4:0] r_id_ex_rd;

    // -- EX
    logic [1:0] r_id_ex_alu_op;
    logic [0:0] r_id_ex_alu_src_a;
    logic [1:0] r_id_ex_alu_src_b;

    // -- MEM
    logic r_id_ex_mem_write;
    logic r_id_ex_mem_read;

    // -- WB
    logic r_id_ex_reg_write;
    logic [1:0] r_id_ex_reg_write_src;

    // Data
    logic [31:0] r_id_ex_rd1;
    logic [31:0] r_id_ex_rd2;
    logic [31:0] r_id_ex_imm;

    logic [31:0] r_id_ex_pc;
    logic [31:0] r_id_ex_pc_p4;         // PC + 4 -> next instruction

    // ======= EX =======
    // ALU Controller Declaration
    logic [3:0] w_alu_ctrl;

    alu_controller alu_controller_inst (
        .alu_op(r_id_ex_alu_op),
        .funct7(r_id_ex_funct7),
        .funct3(r_id_ex_funct3),

        .alu_ctrl(w_alu_ctrl)
    );

    // ALU Declaration
    logic [31:0] w_alu_A;
    logic [31:0] w_alu_B;
    logic [31:0] w_alu_do;

    logic w_alu_zero;
    logic w_alu_ovf;

    alu alu_inst (
        .alu_ctrl(w_alu_ctrl),

        .A(r_alu_A),
        .B(r_alu_B),
        .alu_do(r_alu_do),

        .zero(w_alu_zero),
        .ovf(w_alu_ovf)
    );

    // ======= EX-MEM Register =======
    // Control Words
    logic [4:0] r_ex_mem_rd;

    // -- MEM
    logic r_ex_mem_mem_write;
    logic r_ex_mem_mem_read;
    logic [31:0] r_ex_mem_mem_write_data;   // Data to be written to data memory
    logic [31:0] r_ex_mem_mem_write_addr;   // Doubles as alu result

    // -- WB
    logic r_ex_mem_reg_write;
    logic [1:0] r_ex_mem_reg_write_src;

    // -- PC
    logic [31:0] r_ex_mem_pc_p4;         // Used for jal as return address

    // ======= MEM =======

    // ======= MEM-WB Register =======
    logic r_mem_wb_reg_write;

    logic [1:0] r_mem_wb_reg_write_src;
    logic [4:0] r_mem_wb_rd;

    // Data
    logic [31:0] r_mem_wb_alu_result;
    logic [31:0] r_mem_wb_read_data;
    logic [31:0] r_mem_wb_pc_p4;         // Used for jal as return address

    // ======= WB =======
    write_back write_back_inst (
        .WB_RegWrite(r_mem_wb_reg_write),
        .WB_RD(r_mem_rd),
        .RegWriteSrc(r_mem_wb_reg_write_src),

        .AluResult(r_mem_wb_alu_result),
        .ReadData(r_mem_wb_read_data),
        .PCPlus4(r_mem_wb_pc_p4),

        .ID_RegWrite(w_wb_id_reg_write),
        .ID_RegWriteData(w_wb_id_reg_write_data),
        .ID_RD(w_wb_id_rd)
    );

    // ======= Forwarding =======

    // ======= Hazard =======

endmodule;
