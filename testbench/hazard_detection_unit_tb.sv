// hazard_detection_unit_tb.sv

module hazard_detection_unit_tb;
    logic [4:0] idex_rs1_addr;
    logic [4:0] idex_rs2_addr;
    logic[4:0] exmem_rd_addr;
    logic exmem_reg_write;
    logic [4:0] memwb_rd_addr;
    logic memwb_reg_write;
    logic [1:0] forward_a;
    logic [1:0] forward_b;

    hazard_detection_unit uut (
        .idex_rs1_addr(idex_rs1_addr),
        .idex_rs2_addr(idex_rs2_addr),
        .exmem_rd_addr(exmem_rd_addr),
        .exmem_reg_write(exmem_reg_write),
        .memwb_rd_addr(memwb_rd_addr),
        .memwb_reg_write(memwb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)

    );

    initial begin
        // Test 1: no hazard - nothing matches
        idex_rs1_addr = 5'd1;
        idex_rs2_addr = 5'd2;
        exmem_rd_addr = 5'd9;
        exmem_reg_write = 1;
        memwb_rd_addr = 5'd8;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=00 fb=00");

        // Test 2: EX/MEM hazard on rs1
        idex_rs1_addr = 5'd3;
        idex_rs2_addr = 5'd2;
        exmem_rd_addr = 5'd3;
        exmem_reg_write = 1;
        memwb_rd_addr = 5'd8;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=01 fb=00");

        // Test 3: MEM/WB hazard on rs2
        idex_rs1_addr = 5'd1;
        idex_rs2_addr = 5'd5;
        exmem_rd_addr = 5'd9;
        exmem_reg_write = 1;
        memwb_rd_addr = 5'd5;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=00 fb=10");

        // Test 4: both EX/MEM and MEM/WB match rs1 - priorit should be EX/MEM
        idex_rs1_addr = 5'd7;
        idex_rs2_addr = 5'd2;
        exmem_rd_addr = 5'd7;
        exmem_reg_write = 1;
        memwb_rd_addr = 5'd7;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=01 fb=00");

        // Test 5: rs1 match but exmem_reg_write=0 - should NOT forward
        idex_rs1_addr = 5'd4;
        idex_rs2_addr = 5'd2;
        exmem_rd_addr = 5'd4;
        exmem_reg_write = 0;
        memwb_rd_addr = 5'd7;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=00 fb=00");

        // Test 6: match but rd_addr=0 (x0) - should NOT forward
        idex_rs1_addr = 5'd0;
        idex_rs2_addr = 5'd2;
        exmem_rd_addr = 5'd0;
        exmem_reg_write = 1;
        memwb_rd_addr = 5'd8;
        memwb_reg_write = 1;
        #1;
        $display("Test | fa=%b fb=%b", forward_a, forward_b);
        $display("expect: fa=00 fb=00");

        $display("Testbench complete.");
        $finish;
    end
endmodule 




        