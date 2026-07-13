// program_counter.sv
// holds address of the current instruction

module program_counter(
    input logic clk,
    input logic rst,
    input logic [31:0] pc_next,
    output logic [31:0] pc

);


    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'h00000000;
        else
            pc <= pc_next;
    end
endmodule