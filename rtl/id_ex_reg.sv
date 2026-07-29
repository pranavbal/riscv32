// id_ex_reg.sv
// Pipeline register between ID and EX stage

module id_ex_reg (
    input logic clk,
    input logic rst,
    input logic stall,
    input logic flush,
    // carried forward from IF and then through IF_ID
    input logic [31:0] pc_current_in,

    // ins from the ID stage
    input logic [31:0] rs1_data_in,
    input logic [31:0] rs2_data_in,
    input logic [31:0] imm_in,
    input logic [4:0] rs1_addr_in,
    input logic [4:0] rs2_addr_in,
    input logic [4:0] rd_addr_in,
    input logic [2:0] funct3_in,

    // control signals produced by control_unit inside iD
    input logic reg_write_in,
    input logic we_in,
    input logic alu_src_in,
    input logic [3:0] alu_control_in,
    input logic [1:0] mem_to_reg_in,
    input logic branch_in,
    input logic jump_in,
    input logic auipc_in,
    input logic jalr_in,

//outputs
    output logic [31:0] pc_current_out,

    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] imm_out,
    output logic [4:0] rs1_addr_out,
    output logic [4:0] rs2_addr_out,
    output logic [4:0] rd_addr_out,
    output logic [2:0] funct3_out,

    output logic reg_write_out,
    output logic we_out,
    output logic alu_src_out,
    output logic [3:0] alu_control_out,
    output logic [1:0] mem_to_reg_out,
    output logic branch_out,
    output logic jump_out,
    output logic auipc_out,
    output logic jalr_out
);

    always_ff @(posedge clk) begin
        if (rst || flush || stall ) begin
            pc_current_out <= 32'b0;
            rs1_data_out <= 32'b0;
            rs2_data_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_addr_out <= 5'b0;
            rs2_addr_out <= 5'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            reg_write_out <= 1'b0;
            we_out <= 1'b0;
            alu_src_out <= 1'b0;
            alu_control_out <= 4'b0;
            mem_to_reg_out <= 2'b0;
            branch_out <= 1'b0;
            jump_out <= 1'b0;
            auipc_out <= 1'b0;
            jalr_out <= 1'b0;
        end else begin
            pc_current_out <= pc_current_in;
            rs1_data_out <= rs1_data_in;
            rs2_data_out <= rs2_data_in;
            imm_out <= imm_in;
            rs1_addr_out <= rs1_addr_in;
            rs2_addr_out <= rs2_addr_in;
            rd_addr_out <= rd_addr_in;
            funct3_out <= funct3_in;
            reg_write_out <= reg_write_in;
            we_out <= we_in;
            alu_src_out <= alu_src_in;
            alu_control_out <= alu_control_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out <= branch_in;
            jump_out <= jump_in;
            auipc_out <= auipc_in;
            jalr_out <= jalr_in;
        end
    end
endmodule


            
