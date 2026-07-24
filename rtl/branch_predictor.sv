// branch_predictor.sv
// 2-bit predictor of taken/not-taken using a 64-entry direct-mapped table

module branch_predictor (
    input logic clk,
    input logic rst,
    
    // Prediction lookup (done in IF)
    input logic [31:0] predict_pc,
    output logic predict_taken,

    // Update (done when branch is finalized in EX) - all these ports are about branch instruction in ex
    input logic update_valid,   // check if there is a branch to update cycle
    input logic [31:0] update_pc, // branch instruction in ex 's PC
    input logic actual_taken //  if its zero or not

);
    // 64 entries, indexed by PC bits [7:2] (word-aligned, 6 index bits)
    logic [1:0] counter_table [0:63];

    integer i;

    // Prediction: look up table, predict if top bit is 1
    assign predict_taken = counter_table[predict_pc[7:2]][1];

    // Update: increment/decrement the counter for the resolved branch
    always_ff @(posedge clk) begin
        if (rst) begin 
            for (i = 0; i < 64; i = i + 1)
                counter_table[i] <= 2'b01; // initialize to "weakly not-taken"
        end else if (update_valid) begin 
            if (actual_taken) begin
                if (counter_table[update_pc[7:2]] != 2'b11)
                    counter_table[update_pc[7:2]] <= counter_table[update_pc[7:2]] + 1'b1;
            end else begin
                if (counter_table[update_pc[7:2]] != 2'b00)
                    counter_table[update_pc[7:2]] <= counter_table[update_pc[7:2]] - 1'b1;
            end
        end
    end
endmodule 


