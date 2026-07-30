// cpu_pipeline_tb.sv

module cpu_pipeline_tb;
    logic clk; 
    logic rst;

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
        // 5-stage pipeline
        repeat (25) @(posedge clk);
        #1;

        $display("------Pipeline verification------");
        $display("x1=%0d (expect 5)", uut.ID.regfile.registers[1]);
        $display("x2=%0d (expect 10)", uut.ID.regfile.registers[2]);
        $display("x3=%0d (expect 15)", uut.ID.regfile.registers[3]);
        $display("x4=%0d (expect 10)", uut.ID.regfile.registers[4]);
        $display("x5=%0d (expect 10)", uut.ID.regfile.registers[5]);
        $display("x6=%0d (expect 15)", uut.ID.regfile.registers[6]);
        $display("x7=%0d (expect 0, should be skipped by branch)", uut.ID.regfile.registers[7]);
        $display("x8=%0d (expect 77)", uut.ID.regfile.registers[8]);


        if (uut.ID.regfile.registers[1] == 5 &&
            uut.ID.regfile.registers[2] == 10 &&
            uut.ID.regfile.registers[3] == 15 &&
            uut.ID.regfile.registers[4] == 10 &&
            uut.ID.regfile.registers[5] == 10 &&
            uut.ID.regfile.registers[6] == 15 &&
            uut.ID.regfile.registers[7] == 0 &&
            uut.ID.regfile.registers[8] == 77)
            $display("All tests passed - forwarding, load-use stall, and branch/flush all verified");
        else
            $display("Test failed - check values above");

        $display("Testbench complete.");
        $finish;
    end
endmodule