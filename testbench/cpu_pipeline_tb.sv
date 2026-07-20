// cpu_pipeline_tb.sv

module cpu_pipeline_tb;
    logic clk, rst;

    cpu_pipeline uut (
        .clk(clk),
        .rst(rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        @(posedge clk); #1;
        rst = 0;

        // Run enough cycles for 11 instruction to go through
        // 5-stage pipeline (11 instructions and 4 cycles)
        repeat (25) @(posedge clk);
        #1;

        $display("------Pipeline verification------");
        $display("x1=%0d (expect 5)", uut.ID.regfile.registers[1]);
        $display("x2=%0d (expect 10)", uut.ID.regfile.registers[2]);
        $display("x3=%0d (expect 15)", uut.ID.regfile.registers[3]);
        $display("x4=%0d (expect 15)", uut.ID.regfile.registers[4]);

        if (uut.ID.regfile.registers[1] == 5 &&
            uut.ID.regfile.registers[2] == 10 &&
            uut.ID.regfile.registers[3] == 15 &&
            uut.ID.regfile.registers[4] == 15)
            $display("All tests passed - pipeline pass 1 verified");
        else
            $display("Test failed - check values above");

        $display("Testbench complete.");
        $finish;
    end
endmodule