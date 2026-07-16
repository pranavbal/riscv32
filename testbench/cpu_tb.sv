// cpu_tv.sv

module cpu_tb;
    logic clk, rst;

    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin 
        // Apply reset
        rst = 1; #10;

        // Release reset and let the peogram run through all 5 instructions
        rst = 0; #110;

        // Check final register and memory values
        $display("=== Single-Cycle CPU verification ===");
        $display("x1=%0d (expect 5)", uut.dp.regfile.registers[1]);
        $display("x2=%0d (expect 5)", uut.dp.regfile.registers[2]);
        $display("x3=%0d (expect 0, should be skipped by BEQ)", uut.dp.regfile.registers[3]);
        $display("x4=%0d (expect 42)", uut.dp.regfile.registers[4]);
        $display("x5=%0d (expect 24, JAL return address)", uut.dp.regfile.registers[5]);
        $display("x6=%0d (expect 0, should be skipped by JAL)", uut.dp.regfile.registers[6]);
        $display("x7=%0d (expect 88)", uut.dp.regfile.registers[7]);
        $display("x8=%0d (expect 0, SUB result)", uut.dp.regfile.registers[8]);
        $display("x9=%0d (expect 1, ANDI result)", uut.dp.regfile.registers[9]);
        $display("x10=%h (expect 12345000, LUI result)", uut.dp.regfile.registers[10]);


        if (uut.dp.regfile.registers[1] == 5 &&
            uut.dp.regfile.registers[2] == 5 &&
            uut.dp.regfile.registers[3] == 0 &&
            uut.dp.regfile.registers[4] == 42 &&
            uut.dp.regfile.registers[5] == 24 &&
            uut.dp.regfile.registers[6] == 0 &&
            uut.dp.regfile.registers[7] == 88 &&
            uut.dp.regfile.registers[8] == 0 &&
            uut.dp.regfile.registers[9] == 1 &&
            uut.dp.regfile.registers[10] == 32'h12345000) begin
                $display("ALL TESTS PASSED - SINGLE CYCLE CPU VERIFIED");
            end
            else begin
                $display("TEST FAILED - Check values above");
            end

        $display("Testbench complete.");
        $finish;
    end
endmodule