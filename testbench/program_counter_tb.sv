// program_counter_tb.sv

module program_counter_tb;
    logic clk;
    logic rst;
    logic [31:0] pc_next;
    logic [31:0] pc;

    program_counter uut(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // reset it
        rst = 1; pc_next = 32'h00000000; #10;
        $display("RST=1 | pc=%h (expect 00000000)", pc);

        // Release rest, simulate normal PC+4 increments
        rst = 0; pc_next = 32'h00000004; #10;
        $display("pc_next=4 | pc=%h (expect 00000004)", pc);

        pc_next = 32'h00000008; #10;
        $display("pc_next=8 | pc=%h (expect 00000008)", pc);

        pc_next = 32'h0000000C; #10;
        $display("pc_next=C | pc=%h (expect 0000000c)", pc);

        // Simulate a branch jumping far ahead
        pc_next = 32'h00000100; #10;
        $display("branch jump | pc=%h (expect 00000100)", pc);

        // Apply reset again
        rst = 1; #10;
        $display("RST=1 again | pc=%h (expect 00000000)", pc);

        $display("Testbench complete.");
        $finish;
    end
endmodule