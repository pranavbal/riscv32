// register_file_tb.sv

module register_file_tb;

    logic clk, rst, reg_write;
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rs1_data, rs2_data, rd_data;

    register_file uut(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_data(rd_data)

    );

    // clock
    initial clk =0;
    always #5 clk = ~clk;

    initial begin 
        // Initialize 
        rst = 1; reg_write = 0;
        rs1_addr = 0; rs2_addr = 0;
        rd_addr = 0; rd_data =0;
        #10;

        // Release reset
        rst = 0;
        #10;

        // Write 42 into register x1
        rd_addr = 5'd1; rd_data = 32'd42; reg_write = 1;
        #10;

        //Write 100 into register x2
        rd_addr = 5'd2; rd_data = 32'd100; reg_write = 1;
        #10;

        // Stop writing
        reg_write =0;

        // Read x1 and x2
        rs1_addr = 5'd1; rs2_addr = 5'd2;
        #10;

        $display("rs1_addr=1 | rs1_data=%0d (expect 42)", rs1_data);
        $display("rs2_addr=2 | rs2_data=%0d (expect 100)", rs2_data);

        // Try reading x0 - should always be 0
        rs1_addr = 5'd0;
        #10;
        $display("rs1_addr=0 | rs1_data=%0d (expect 0)", rs1_data);

        // Try writing to x0 - should be ignored
        rd_addr = 5'd0; rd_data = 32'd999; reg_write = 1;
        #10;
        rs1_addr = 5'd0;
        #10;
        $display("wrote 999 to x0 | rs1_data=%0d (expect 0)", rs1_data);

        $display("Testbench complete.");
        $finish;
    end
endmodule


