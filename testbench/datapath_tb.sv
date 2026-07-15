// datapath_tb.sv

module datapath_tb;
    logic clk, rst;

    datapath uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // reset everything
        rst = 1; #10;
        $display("RST = 1 | pc=%h (expect 00000000)", uut.pc_current);

        // release reset - Cycle 1 executes: ADDI x1, x0, 5
        rst = 0; #10;
        $display("Cycle 1 | pc=%h instr=%h opcode=%b (expect pc=00000004)", uut.pc_current, uut.instruction, uut.opcode);
        
        // Cycle 2 executes - ADD x2, x0, 10
        #10;
        $display("Cycle 2 | pc=%h instr=%h opcode=%b (expect pc=00000008)", uut.pc_current, uut.instruction, uut.opcode);

        // Cycle 3 - ADD x3, x1, x2
        #10;
        $display("Cycle 3 | pc=%h instr=%h opcode=%b (expect pc=0000000c)", uut.pc_current, uut.instruction, uut.opcode);
        
        //Cycle 4 - SW x3, 0(x0)
        #10;
        $display("Cycle 4 | pc=%h instr=%h opcode=%b (expect pc=00000010)", uut.pc_current, uut.instruction, uut.opcode);
        
        //Cycle 5 - LW x4, 0(x0)
        #10;
        $display("Cycle 5 | pc=%h instr=%h opcode=%b (expect pc=00000014)", uut.pc_current, uut.instruction, uut.opcode);
        
        // Check final register and memory values
        $display("x1=%0d (expect 5)", uut.regfile.registers[1]);
        $display("x2=%0d (expect 10)", uut.regfile.registers[2]);
        $display("x3=%0d (expect 15)", uut.regfile.registers[3]);
        $display("x4=%0d (expect 15)", uut.regfile.registers[4]);
        $display("mem[0]=%0d (expect 15)", uut.dmem.mem[0]);

        $display("Testbench complete.");
        $finish;
    end
endmodule