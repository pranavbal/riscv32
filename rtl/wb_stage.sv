// wb_stage.sv
// Wraps the write-back mux for WB stage

module wb_stage (
    input logic [31:0] alu_result_in,
    input logic [31:0] data_read_memory_in,
    input logic [31:0] pc_plus_4_in,
    input logic [31:0] imm_in,
    input logic [1:0] mem_to_reg_in,

    output logic [31:0] write_back_data_out
);

    always_comb begin
        case (mem_to_reg_in)
            2'b00: write_back_data_out = alu_result_in;
            2'b01: write_back_data_out = data_read_memory_in;
            2'b10: write_back_data_out = pc_plus_4_in;
            2'b11: write_back_data_out = imm_in;
            default: write_back_data_out = alu_result_in;
        endcase
    end
endmodule 