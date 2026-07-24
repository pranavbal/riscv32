// branch_target_buffer.sv
// Caches the target address for taken branches

module branch_target_buffer (
    input logic clk,
    input logic rst,

    // lookup for branch target (in IF stage)
    input logic [31:0] lookup_pc,
    output logic [31:0] btb_target,
    output logic btb_valid,

    // Update (done when branch is true in EX and its taken)
    input logic update_valid,
    input logic [31:0] update_pc,
    input logic [31:0] update_target

);

    logic [31:0] target_table [0:63];
    logic valid_table [0:63];

    integer i;

    assign btb_target = target_table[lookup_pc[7:2]];
    assign btb_valid = valid_table[lookup_pc[7:2]];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1)
                valid_table[i] <= 1'b0;
        end else if (update_valid) begin
            target_table[update_pc[7:2]] <= update_target;
            valid_table[update_pc[7:2]] <= 1'b1;
        end
    end
endmodule 