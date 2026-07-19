// mem_stage.sv
// Wraps data_memory for MEM stage

module mem_stage (
    input logic clk,
    input logic we_in,
    input logic [31:0] alu_result_in,
    input logic [31:0] rs2_data_in,

    output logic [31:0] mem_read_data_out

);

    data_memory dmem (
        .clk(clk),
        .we(we_in),
        .addr(alu_result_in),
        .wd(rs2_data_in),
        .rd(mem_read_data_out)
    );

endmodule

