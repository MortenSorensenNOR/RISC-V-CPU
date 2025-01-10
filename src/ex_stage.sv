`timescale 1ns/1ps

module ex_stage (
);

    // ========== ALU Controller ==========
    alu_controller alu_controller_inst (
        .alu_op,
        .funct7,
        .funct3,
        .alu_ctrl
    );

    // ========== ALU Src A ==========
    always_comb begin
    end

    // ========== ALU Src B ==========
    always_comb begin
    end

    // ========== ALU ==========
    alu alu_inst (
        .alu_ctrl,

        .A,
        .B,
        .alu_do,

        .zero,
        .ovf
    );

endmodule
