// mem_wb_reg.sv
// pipeline between mem and wb

module mem_wb_reg(
    input logic clk,
    input logic rst,

    // possible write back sources
    input logic [31:0] alu_result_in,
    input logic [31:0] mem_read_data_in,
    input logic [4:0] rd_addr_in,
    input logic [31:0] pc_plus_4_in,
    input logic [31:0] imm_in,

    // control signals 
    input logic reg_write_in,
    input logic [1:0] mem_to_reg_in,

    output logic [31:0] alu_result_out,
    output logic [31:0] mem_read_data_out,
    output logic [4:0] rd_addr_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] imm_out,

    // control signals 
    output logic reg_write_out,
    output logic [1:0] mem_to_reg_out

);

    always_ff @(posedge clk) begin
        if (rst) begin
            alu_result_out <= 32'b0;
            mem_read_data_out <= 32'b0;
            rd_addr_out <= 5'b0;
            pc_plus_4_out <= 32'b0;
            imm_out <= 32'b0;
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 2'b0;
        end else begin
            alu_result_out <= alu_result_in;
            mem_read_data_out <= mem_read_data_in;
            rd_addr_out <= rd_addr_in;
            pc_plus_4_out <= pc_plus_4_in;
            imm_out <= imm_in;
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
