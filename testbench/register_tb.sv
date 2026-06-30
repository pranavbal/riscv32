// register_tb.sv
// Testbench for 32-bit register

module register_tb;

    logic clk, rst;
    logic [31:0] d, q;

    register uut(
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; d = 32'hDEADBEEF; #10; // reset everything first
        $display("RST=1 | d=%h | q=%h (expect q=00000000)", d, q);

        rst = 0; d = 32'hDEADBEEF; #10; //load value into d
        $display("RST=0 | d=%h | q=%h (expect q=DEADBEEF)", d, q);

        rst = 0; d = 32'hCAFEBABE; #10; //load another val
        $display("RST=0 | d=%h | q=%h (expect q=CAFEBABE)", d, q);

        rst = 1; d = 32'hCAFEBABE; #10; //reset again
        $display("RST=1 | d=%h | q=%h (expect q=00000000)", d, q);

        $display("Testbench complete.");
        $finish;
    end
endmodule