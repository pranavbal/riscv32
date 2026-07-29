// IF_ID pipeline register
// pipeline register between IF and ID stages

module if_id_reg (
    input logic clk,
    input logic rst,
    input logic stall,
    input logic flush,
    input logic [31:0] instruction_in,
    input logic [31:0] pc_current_in,
    output logic [31:0] instruction_out,
    output logic [31:0] pc_current_out
);

    always_ff @(posedge clk) begin
        if (rst || flush) begin
            instruction_out <= 32'b0;
            pc_current_out <= 32'b0;
        end else if (stall) begin
            instruction_out <= instruction_out;  // stall
            pc_current_out <= pc_current_out;    // stall
        end else begin
            instruction_out <= instruction_in;
            pc_current_out <= pc_current_in;
        end
    end
endmodule
