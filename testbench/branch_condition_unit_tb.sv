// branch_condition_unit_tb.sv

module branch_condition_unit_tb;
    logic [2:0] funct3;
    logic zero;
    logic [31:0] alu_result;
    logic branch_taken;

    branch_condition_unit uut (
        .funct3(funct3),
        .zero(zero),
        .alu_result(alu_result),
        .branch_taken(branch_taken)
    );

    initial begin
        // Test 1: BEQ - zero is 1 so should be taken
        funct3 = 3'b000; zero = 1; alu_result = 32'd0;
        #1;
        $display("BEQ (equal) | taken=%b", branch_taken);
        $display("expect: taken=1");

        // Test 2: BEQ - zero is 0 so shouldn't be taken
        funct3 = 3'b000; zero = 0; alu_result = 32'd5;
        #1;
        $display("BEQ (not equal) | taken=%b", branch_taken);
        $display("expect: taken=0");

        // Test 3: BNE - zero is 0 so should be taken
        funct3 = 3'b001; zero = 0; alu_result = 32'd5;
        #1;
        $display("BNE (not equal) | taken=%b", branch_taken);
        $display("expect: taken=1");

        // Test 4: BNE - zero is 1 so shouldn't be taken
        funct3 = 3'b001; zero = 1; alu_result = 32'd0;
        #1;
        $display("BNE (not equal) | taken=%b", branch_taken);
        $display("expect: taken=0");

        // Test 5: BLT - rs1 < rs2  alu_result is 1 so should be taken
        funct3 = 3'b100; zero = 0; alu_result = 32'd1;
        #1;
        $display("BLT (less than) | taken=%b", branch_taken);
        $display("expect: taken=1");

        // Test 6: BLT - rs1 >= rs2  alu_result is 0 so shouldn't be taken
        funct3 = 3'b100; zero = 0; alu_result = 32'd0;
        #1;
        $display("BLT (not less than) | taken=%b", branch_taken);
        $display("expect: taken=0");

        // Test 7: BGE - rs1 >= rs2  alu_result is 0 so should be taken
        funct3 = 3'b101; zero = 0; alu_result = 32'd0;
        #1;
        $display("BGE (greater/equal) | taken=%b", branch_taken);
        $display("expect: taken=1");

        // Test 8: BGE - rs1 < rs2  alu_result is 1 so shouldn't be taken
        funct3 = 3'b101; zero = 0; alu_result = 32'd1;
        #1;
        $display("BGE (less than) | taken=%b", branch_taken);
        $display("expect: taken=0");

        // Test 9: BLTU - rs1 < rs2 unsigned  alu_result is 1 so should be taken
        funct3 = 3'b110; zero = 0; alu_result = 32'd1;
        #1;
        $display("BLTU (less than) | taken=%b", branch_taken);
        $display("expect: taken=1");

        // Test 10: BGEU - rs1 >= rs2 unsigned  alu_result is 0 so should be taken
        funct3 = 3'b111; zero = 0; alu_result = 32'd0;
        #1;
        $display("BGEU (greater/equal) | taken=%b", branch_taken);
        $display("expect: taken=1");

        $display("Testbench complete.");
        $finish;

    end

endmodule 





