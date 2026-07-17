// ex_mem_reg.sv

module ex_mem_reg(
    input logic clk,
    input logic rst,

    // values by EX stage
    input logic [31:0] alu_result_in,
    input logic [31:0] rs2_data_in,
    input logic [31:0] pc_plus_4_in,
    input logic [31:0] imm_in,
    input logic [4:0] rd_addr_in,
    input logic zero_in,

    // control signals passed forward
    input logic reg_write_in,
    input logic we_in,
    input logic [1:0] mem_to_reg_in,

    // 
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] imm_out,
    output logic [4:0] rd_addr_out,
    output logic zero_out,

    // 
    output logic reg_write_out,
    output logic we_out,
    output logic [1:0] mem_to_reg_out

);

always_ff @(posedge clk) begin
    if (rst) begin
        alu_result_out <= 32'b0;
        rs2_data_out <= 32'b0;
        pc_plus_4_out <= 32'b0;
        imm_out <= 32'b0;
        rd_addr_out <= 5'b0;
        zero_out <= 1'b0;
        reg_write_out <= 1'b0;
        we_out <= 1'b0;
        mem_to_reg_out <= 2'b0;
    end else begin
        alu_result_out <= alu_result_in;
        rs2_data_out <= rs2_data_in;
        pc_plus_4_out <= pc_plus_4_in;
        imm_out <= imm_in;
        rd_addr_out <= rd_addr_in;
        zero_out <= zero_in;
        reg_write_out <= reg_write_in;
        we_out <= we_in;
        mem_to_reg_out <= mem_to_reg_in;
    end
end
endmodule 
        



    

    

