// instruction_decoder_tb.sv

module instruction_decoder_tb;
    logic [31:0] instruction;
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    instruction_decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    initial begin
        // ADD x3, x1, x2
        // funct7=0000000, rs2=00010, rs1=00001, funct3=000, rd=00011, opcode=0110011
        instruction = 32'b0000000_00010_00001_000_00011_0110011; #10;
        $display("ADD | opcode=%b rd=%0d funct3=%b rs1=%0d rs2=0%d funct7=%b", opcode, rd, funct3, rs1, rs2, funct7);
        $display("expect: 0110011 3 000 1 2 0000000");

        // SUB x5, x1, x2
        // funct7 = 0100000, rs2=00010, rs1=00001, funct3=000, rd=00101, opcode=0110011
        instruction = 32'b0100000_00010_00001_000_00101_0110011; #10;
        $display("SUB | opcode=%b rd=%0d funct3=%b rs1=%0d rs2=0%d funct7=%b", opcode, rd, funct3, rs1, rs2, funct7);
        $display("expect: 0110011 5 000 1 2 0100000");

        // LW x6, 4(x1)
        // imm=000000000100, rs1=00001, funct3=010, rd=00110, opcode=0000011
        instruction = 32'b000000000100_00001_010_00110_0000011;#10;
         $display("LW | opcode=%b rd=%0d funct3=%b rs1=0%d rs2=0%d funct7=%b", opcode, rd, funct3, rs1, rs2, funct7);
         $display("expect: 0000011 6 010 1 x(4) x(0000000) (rs2 and func7 are garbage for I-type)");

         $display("Testbench complete");
         $finish;
    end
endmodule
