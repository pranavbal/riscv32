// branch_target_buffer_tb.sv

module branch_target_buffer_tb;
    logic clk;
    logic rst;
    logic [31:0] lookup_pc;
    logic [31:0] btb_target;
    logic btb_valid;

    // the branch instruction in EX
    logic update_valid;
    logic [31:0] update_pc;
    logic [31:0] update_target;

    branch_target_buffer uut (
        .clk(clk),
        .rst(rst),
        .lookup_pc(lookup_pc),
        .btb_target(btb_target),
        .btb_valid(btb_valid),
        .update_valid(update_valid),
        .update_pc(update_pc),
        .update_target(update_target)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        lookup_pc = 32'h00000030;
        update_valid = 0;
        update_pc = 32'h00000030;
        update_target = 32'h00000000;
        @(posedge clk); #1;
        rst = 0;

        // Test 1: fresh slot - shouldn't be valid
        lookup_pc = 32'h00000030;
        #1;
        $display("Test 1 | btb_valid=%b btb_target=%h", btb_valid, btb_target);
        $display("expect: btb_valid=0");

        // Test 2: update slot 0x30 (12 in the table) with target 0x18
        update_valid = 1;
        update_pc = 32'h00000030;
        update_target = 32'h00000018;
        @(posedge clk); #1;
        update_valid = 0;
        lookup_pc = 32'h00000030;
        #1;
        $display("Test 2 | btb_valid=%b btb_target=%h", btb_valid, btb_target);
        $display("expect: btb_valid=1 btb_target=00000018");

        // Test 3: update again with a NEW target 
        update_valid = 1;
        update_pc = 32'h00000030;
        update_target = 32'h00000024;
        @(posedge clk); #1;
        update_valid = 0;
        #1;
        $display("Test 3 | btb_valid=%b btb_target=%h", btb_valid, btb_target);
        $display("expect: btb_valid=1 btb_target=00000024");

        // Test 4: different address never touched before so should be invalid
        lookup_pc = 32'h00000080;
        #1;
        $display("Test 4 | btb_valid=%b btb_target=%h", btb_valid, btb_target);
        $display("expect: btb_valid=0");

        $display("Testbench complete.");
        $finish;
    end
endmodule 