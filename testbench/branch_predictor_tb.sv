// branch_predictor_tb.sv

module branch_predictor_tb;
    logic clk;
    logic rst;
    logic [31:0] predict_pc;
    logic predict_taken;
    logic update_valid;
    logic [31:0] update_pc;
    logic actual_taken;

    branch_predictor uut (
        .clk(clk),
        .rst(rst),
        .predict_pc(predict_pc),
        .predict_taken(predict_taken),
        .update_valid(update_valid),
        .update_pc(update_pc),
        .actual_taken(actual_taken)

    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        predict_pc = 32'h00000030;
        update_valid = 0;
        update_pc = 32'h00000030;
        actual_taken = 0;
        @(posedge clk); #1;
        rst = 0;

        // Test 1: starting (counter table never updated) - should predict not-taken
        predict_pc = 32'h00000030;
        #1;
        $display("Test 1 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=0");

        // Test 2: update withj taken -> 01 becomes 10, should predict talem
        update_valid = 1;
        update_pc = 32'h00000030;
        actual_taken = 1;
        @(posedge clk); #1;
        update_valid = 0;
        predict_pc = 32'h00000030;
        #1;
        $display("Test 2 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=1");

        // Test 3: update with taken again -> 10 becomes 11, predicts taken
        update_valid = 1;
        actual_taken = 1;
        @(posedge clk); #1;
        update_valid = 0;
        #1;
        $display("Test 3 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=1");

        // Test 4: check if maxed -> update taken again, predicts taken 
        update_valid = 1;
        actual_taken = 1;
        @(posedge clk); #1;
        update_valid = 0;
        #1;
        $display("Test 4 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=1");

        // Test 5: one not-taken -> 11 becomes outcome still predicts taken
        update_valid = 1;
        actual_taken = 0;
        @(posedge clk); #1;
        update_valid = 0;
        #1;
        $display("Test 5 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=1");

        // Test 6: second not-taken -> 10 becomes 01, now should predict not-taken
        update_valid = 1;
        actual_taken = 0;
        @(posedge clk); #1;
        update_valid = 0;
        #1;
        $display("Test 6 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=0");

        // Test 7: different PC (diff slot), should be independant and say not-taken
        predict_pc = 32'h00000080;
        $display("Test 7 | predict_taken=%b", predict_taken);
        $display("expect: predict_taken=0");

        $display("Testbench complete.");
        $finish;
    end
endmodule 