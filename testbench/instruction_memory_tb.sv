// instruction_memory_tb.sv

module instruction_memory_tb;
    logic [31:0] addr;
    logic [31:0] instruction;

    instruction_memory uut (
        .addr(addr),
        .instruction(instruction)
    );

    initial begin
        // read address 0 - should be the first instruction
        addr = 32'd0; #10;
        $display("addr=0 | instruction=%h (expect 00208133)", instruction);

        // read address 4 - second instruction
        addr = 32'd4; #10;
        $display("addr=4 | instruction=%h (expect 00308233)", instruction);
        
        // read address 8 - third instruction
        addr = 32'd8; #10;
        $display("addr=8 | instruction=%h (expect 00c58513)", instruction);

        // read address 12 - fourth instruction
        addr=32'd12; #10;
        $display("addr=12 | instruction=%h (expect 00202223)", instruction);

        // read address 16 = fifth instruction
        addr=32'd16; #10;
        $display("addr=16 | instruction=%h (expect 00202503)", instruction);

        $display("Testbench complete.");
        $finish;
    end
endmodule