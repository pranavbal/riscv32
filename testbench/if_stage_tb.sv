module if_stage_tb;
    logic clk, rst;
    logic [31:0] pc_next_in;
    logic [31:0]  pc_current_out, instruction_out, pc_plus_4_out;

    if_stage uut (
        .clk(clk),
        .rst(rst),
        .pc_next_in(pc_next_in),
        .pc_current_out(pc_current_out),
        .instruction_out(instruction_out),
        .pc_plus_4_out(pc_plus_4_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Test 1: reset should make everything 0
        rst = 1;
        pc_next_in = 32'hFFFFFFFF; //program_counter ignores this since rst is 1
        @(posedge clk); #1;
        $display("After reset | pc=%h instr=%h pc4=%h", pc_current_out, instruction_out, pc_plus_4_out);
        $display("expect: pc=00000000 instr=00500093 pc4=00000004");

        // Test 2: release reset, make pc go to next address which is 4
        rst = 0;
        pc_next_in = 32'h00000004;
        @(posedge clk); #1;
        $display("Cycle 1 | pc=%h instr=%h pc4=%h", pc_current_out, instruction_out, pc_plus_4_out);
        $display("expect: pc=00000004 instr=00500113 pc4=00000008");

        // Test 3: advance PC to address 8
        pc_next_in = 32'h00000008;
        @(posedge clk); #1;
        $display("Cycle 2 | pc=%h instr=%h pc4=%h", pc_current_out, instruction_out, pc_plus_4_out);
        $display("expect: pc=00000008 instr=00208463 pc4=0000000c");

        // Test 4: drive jump value
        pc_next_in = 32'h00000020;
        @(posedge clk); #1;
        $display("Cycle 3 (jump) | pc=%h instr=%h pc4=%h", pc_current_out, instruction_out, pc_plus_4_out);
        $display("expect: pc=00000020 instr=40110433 pc4=00000024");

        $display("Testbench complete.");
        $finish;
    end
endmodule 