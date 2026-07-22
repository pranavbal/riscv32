// forwarding_unit_tb.sv

module forwarding_unit_tb;
    logic [31:0] idex_rs1_data;
    logic [31:0] idex_rs2_data;
    logic [31:0] exmem_alu_result;
    logic [31:0] wb_write_back_data;
    logic [1:0] forward_a;
    logic [1:0] forward_b;
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;

    forwarding_unit uut (
        .idex_rs1_data(idex_rs1_data),
        .idex_rs2_data(idex_rs2_data),
        .exmem_alu_result(exmem_alu_result),
        .wb_write_back_data(wb_write_back_data),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .alu_operand_a(alu_operand_a),
        .alu_operand_b(alu_operand_b)
    );

    initial begin
        idex_rs1_data = 32'd5;
        idex_rs2_data = 32'd10;
        exmem_alu_result = 32'd99;
        wb_write_back_data = 32'd77;

        // Test 1: no forwarding
        forward_a = 2'b00; forward_b = 2'b00;
        #1;
        $display("Test 1 |a=%0d b=%0d", alu_operand_a, alu_operand_b);
        $display("expect: a=5 b=10");

        // Test 2: forward a from EX/MEM
        forward_a = 2'b01; forward_b = 2'b00;
        #1;
        $display("Test 2 |a=%0d b=%0d", alu_operand_a, alu_operand_b);
        $display("expect: a=99 b=10");

        // Test 3: forward b from MEM/MEM
        forward_a = 2'b00; forward_b = 2'b10;
        #1;
        $display("Test 3 |a=%0d b=%0d", alu_operand_a, alu_operand_b);
        $display("expect: a=5 b=77");

        // Test 4: both forwarded at same time from diff sources
        forward_a = 2'b01; forward_b = 2'b10;
        #1;
        $display("Test 4 |a=%0d b=%0d", alu_operand_a, alu_operand_b);
        $display("expect: a=99 b=77");

        $display("Testbench complete.");
        $finish;
    end
endmodule 

