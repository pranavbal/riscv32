// data_memory_tb.sv


module data_memory_tb;
    logic clk;
    logic we;
    logic [31:0] addr;
    logic [31:0] wd;
    logic [31:0] rd;

    data_memory uut(
        .clk(clk),
        .we(we),
        .addr(addr),
        .wd(wd),
        .rd(rd)
    );

    // set clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        //Write 42 to address 0
        we = 1; addr = 32'd0; wd = 32'd42; #10;

        //Write 100 to address 4
        we = 1; addr = 32'd4; wd = 32'd100; #10;

        // Write 999 to address 8
        we = 1; addr = 32'd8; wd = 32'd999; #10;

        //stop writing
        we = 0;

        // Read from address 0
        addr = 32'd0; #10;
        $display("addr=0 | rd=%0d (expect 42)", rd);

         // Read from address 4
        addr = 32'd4; #10;
        $display("addr=4 | rd=%0d (expect 100)", rd);

        // Read from address 8
        addr = 32'd8; #10;
        $display("addr=8 | rd=%0d (expect 999)", rd);

        $display("Testbench complete.");
        $finish;
    end
endmodule