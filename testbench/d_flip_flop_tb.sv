// d_flip_flop_tb.sv


module d_flip_flop_tb;
    // declaring signals
    logic clk, d, q;

    // connect to d_flip_flop
    d_flip_flop uut(
        .clk(clk),
        .d(d),
        .q(q)
    );

    //Generate clock - toggles every 5 time units
    
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        d = 0; #10;
        $display("clk edge | d=%b | q=%b (expect 0)", d, q);

        d = 1; #10;
        $display("clk edge | d=%b | q=%b (expect 1)", d, q);

        d = 0; #10;
        $display("clk edge | d=%b | q=%b (expect 0)", d, q);

        d = 1; #10;
        $display("clk edge | d=%b | q=%b (expect 1)", d, q);

        $display("Testbench complete.");
        $finish;
    end

endmodule

