// id_stage.sv
// Wraps instruction_decoder, immediate generator, control_unit, register file into single ID block

module id_stage (
    // inputs
    input logic clk,
    input logic rst,
    input logic [31:0] instruction_in,

    //outputs
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic [4:0] rs1_addr_out,
    output logic [4:0] rs2_addr_out,
    output logic [4:0] rd_addr_out,
    output logic [31:0] imm_out,

    // control unit signals
    output logic reg_write_out,
    output logic we_out,
    output logic alu_src_out,
    output logic [3:0] alu_control_out,
    output logic [1:0] mem_to_reg_out,
    output logic branch_out,
    output logic jump_out,

    // write-back inputs for register file
    input logic [31:0] wb_data,
    input logic [4:0] wb_rd_addr,
    input logic       wb_reg_write
);


    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;

    instruction_decoder decoder (
        .instruction(instruction_in),
        .opcode(opcode),
        .rd(rd_addr_out),
        .funct3(funct3),
        .rs2(rs2_addr_out),
        .rs1(rs1_addr_out),
        .funct7(funct7)

    );

    immediate_generator imm_gen (
        .instruction(instruction_in),
        .imm(imm_out)

    );

    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write_out),
        .we(we_out),
        .alu_src(alu_src_out),
        .alu_control(alu_control_out),
        .mem_to_reg(mem_to_reg_out),
        .branch(branch_out),
        .jump(jump_out)

    );

    register_file regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr_out),
        .rs2_addr(rs2_addr_out),
        .rs1_data(rs1_data_out),
        .rs2_data(rs2_data_out),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_data),
        .reg_write(wb_reg_write)

    );
endmodule