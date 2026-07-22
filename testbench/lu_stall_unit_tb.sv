// lu_stall_unit_tb.sv

module lu_stall_unit_tb;
    logic [1:0] idex_mem_to_reg;
    logic [4:0] idex_rd_addr;
    logic [4:0] id_rs1_addr;
    logic [4:0] id_rs2_addr;
    logic stall;

    lu_stall_unit uut (
        .idex_mem_to_reg(idex_mem_to_reg),
        .idex_rd_addr(idex_rd_addr),
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .stall(stall)

    );

    initial begin
        // Test 1: load, rs1 matches - should stall
        idex_mem_to_reg = 2'b01;
        idex_rd_addr = 5'd3;
        id_rs1_addr = 5'd3;
        id_rs2_addr = 5'd7;
        #1;
        $display("Test 1 | stall=%b", stall);
        $display("expect: stall=1");

        // Test 2: load, rs2 matches - should stall
        idex_mem_to_reg = 2'b01;
        idex_rd_addr = 5'd5;
        id_rs1_addr = 5'd1;
        id_rs2_addr = 5'd5;
        #1;
        $display("Test 2 | stall=%b", stall);
        $display("expect: stall=1");

        // Test 3: load, no match - shouldn't stall
        idex_mem_to_reg = 2'b01;
        idex_rd_addr = 5'd9;
        id_rs1_addr = 5'd1;
        id_rs2_addr = 5'd2;
        #1;
        $display("Test 3 | stall=%b", stall);
        $display("expect: stall=0");

        // Test 4: NOT a load, rd match - shouldn't stall
        idex_mem_to_reg = 2'b00;
        idex_rd_addr = 5'd3;
        id_rs1_addr = 5'd3;
        id_rs2_addr = 5'd7;
        #1;
        $display("Test 4 | stall=%b", stall);
        $display("expect: stall=0");

        // Test 5: load, but rd = 0 - shouldn't stall
        idex_mem_to_reg = 2'b01;
        idex_rd_addr = 5'd0;
        id_rs1_addr = 5'd0;
        id_rs2_addr = 5'd2;
        #1;
        $display("Test 5 | stall=%b", stall);
        $display("expect: stall=0");

        $display("Testbench complete.");
        $finish;
    end
endmodule 
