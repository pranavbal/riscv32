// ex_stage.sv
// wraps ALU, and recomputes pc_plus_4 and branch_target

module ex_stage(
    input logic [31:0] pc_current_in,

    input logic [31:0] rs1_data_in,
    input logic [31:0] rs2_data_in,
    input logic [31:0] imm_in,


    input logic alu_src_in,
    input logic [3:0] alu_control_in,

    output logic [31:0] alu_result_out,
    output logic zero_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] branch_target_out

);
    logic [31:0] alu_operand_b;

    assign alu_operand_b = (alu_src_in) ? imm_in : rs2_data_in;

    alu alu_unit(
        .a(rs1_data_in),
        .b(alu_operand_b),
        .alu_control(alu_control_in),
        .result(alu_result_out),
        .zero(zero_out)
    );

    assign pc_plus_4_out = pc_current_in + 32'd4;
    assign branch_target_out = pc_current_in + imm_in;

endmodule
