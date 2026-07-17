// if_id_reg_tb.sv

module if_id_reg_tb;
    logic clk, rst;
    logic [31:0] instruction_in, pc_current_in;
    logic [31:0] instruction_out, pc_current_out;

    if_id_reg uut (
        .clk(clk),
        .rst(rst),
        .instruction_in(instruction_in),
        .pc_current_in(pc_current_in),
        .instruction_out(instruction_out),
        .pc_current_out(pc_current_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // test 1: reset should make everything zero
        rst = 1;
        instruction_in = 32'hDEADBEEF;
        pc_current_in = 32'h00000010;  
        @(posedge clk); #1; 
        $display("After reset|instr=%h pc=%h", instruction_out, pc_current_out);
        $display("expect: 00000000 00000000");

        // Test 2: release reset, drive real values, check one cycle later
        rst = 0;
        instruction_in = 32'h00500093;
        pc_current_in = 32'h00000004;
        @(posedge clk); #1;
        $display("Cycle 1 |instr=%h pc=%h", instruction_out, pc_current_out);
        $display("expect: 00500093 00000004");

        // Test 3: change inputs, confirm that outputs still match
        instruction_in = 32'h00208463;
        pc_current_in = 32'h00000008;
        @(posedge clk); #1;
        $display("Cycle 2 |instr=%h pc=%h", instruction_out, pc_current_out);
        $display("expect: 00208463 00000008");
        
        // Test 4
        instruction_in = 32'hDEADBEEF;
        pc_current_in = 32'h0000000C;
        @(posedge clk); #1;
        $display("Cycle 3 |instr=%h pc=%h", instruction_out, pc_current_out);
        $display("expect: DEADBEEF 0000000c");

        $display("Testbench complete.");
        $finish;
    end
endmodule

