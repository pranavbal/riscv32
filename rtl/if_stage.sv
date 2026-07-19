// if_stage.sv
// wraps program_counter and instruction_memory into one IF stage block

module if_stage (
    input logic clk,
    input logic rst,

    // PC-next comes from outside IF from EX stage
    input logic [31:0] pc_next_in,

    //outputs going into IF_ID register
    output logic [31:0] instruction_out,
    output logic [31:0] pc_current_out
);

    logic [31:0] pc_current;

    program_counter pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next_in),
        .pc(pc_current)
    );

    instruction_memory imem (
        .addr(pc_current),
        .instruction(instruction_out)
    );

    assign pc_current_out = pc_current;

endmodule