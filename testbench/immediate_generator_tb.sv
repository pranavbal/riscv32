// immediate_generator_tb.sv

module immediate_generator_tb;
    logic [31:0] instruction;
    logic [31:0] imm;

    immediate_generator uut(
        .instruction(instruction),
        .imm(imm)
    );

    initial begin
        // I-type: ADDI x1, x0, 5
        // imm = 5, opcode = 0010011
        instruction = 32'b000000000101_00000_000_00001_0010011; #10;
        $display("I-type ADDI } imm=%0d (expect 5)", $signed(imm));

        // I-type: ADDI x1, x0, -1
        // imm = -1, opcod = 0010011
        instruction = 32'b111111111111_00000_000_00001_0010011; #10;
        $display("I-type ADDI | imm=%0d (expect -1)", $signed(imm));

        // S-type: SW x2 8(x1)
        // imm = 8, opcode = 0100011
        instruction = 32'b0000000_00010_00001_010_01000_0100011; #10;
        $display("S-type SW | imm=%0d (expect 8)", $signed(imm));

        // B-type: BEQ x1, x2, 16
        // imm = 16, opcode = 1100011
        instruction = 32'b0_000000_00010_00001_000_1000_0_1100011; #10;
        $display("B-type BEQ | imm=%0d (expect 16)", $signed(imm));

        // U-type: LUI x3, 0x12345
        // imm = 0c23456000, opcode = 0110111
        instruction = 32'b00010010001101000101_00011_0110111; #10;
        $display("U-type LUI | imm=%h (expect12345000)", imm);

        // J-type: JAL x1, 100
        // imm = 100, opcode = 11-1111
        instruction = 32'b0_0000110010_0_00000000_00001_1101111; #10;
        $display("J-type JAL | imm=%0d (expect 100)", $signed(imm));

        $display("Testbench complete.");
        $finish;
    end
endmodule

