// mem_stage_tb.sv

module mem_stage_tb;
    logic clk;
    logic we_in;
    logic [31:0] alu_result_in;
    logic [31:0] rs2_data_in;
    logic [31:0] mem_read_data_out;
    logic [2:0] funct3_in;

    mem_stage uut(
        .clk(clk),
        .we_in(we_in),
        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .mem_read_data_out(mem_read_data_out),
        .funct3_in(funct3_in)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Test 1: store 32-bit value 0x11223344 to address 8
        we_in = 1;
        alu_result_in = 32'd8;
        rs2_data_in = 32'h11223344;
        funct3_in = 3'b010; // SW
        @(posedge clk); #1;

        // Test 2: load - read back address 8
        we_in = 0;
        alu_result_in = 32'd8;
        funct3_in = 3'b010; // LW
        #1;
        $display("LW | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=11223344");

        // Test 3: LB - read byte offset 0 (should be 0x44, positive)
        alu_result_in = 32'd8;
        funct3_in = 3'b000; // LB
        #1;
        $display("LB offset 0 | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=00000044");

        // Test 4: LB - read byte offset 3 (should be 0x11, positive)
        alu_result_in = 32'd11;
        funct3_in = 3'b000; // LB
        #1;
        $display("LB offset 3 | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=00000011");

        // Test 5: SB - store 0xFF at offset 0 (byte address 8), then read back full word to check
        alu_result_in = 32'd8;
        rs2_data_in = 32'hFFFFFFFF; // only bottom byte (0xFF)
        funct3_in = 3'b000; // SB
        we_in = 1;
        @(posedge clk); #1;
        we_in = 0;
        alu_result_in = 32'd8;
        funct3_in = 3'b010; // LW - read the modified word back
        #1;
        $display("LW after SB | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=112233ff");

        // Test 6: LB - negative byte value, to confirm sign extension
        we_in = 1;
        alu_result_in = 32'd20;
        rs2_data_in = 32'h000000FF; // storing byte  0xFF (negaitve cuz its signed)
        funct3_in = 3'b000; // SB
        @(posedge clk); #1;
        we_in = 0;
        alu_result_in = 32'd20;
        funct3_in = 3'b000; // LB - signed
        #1;
        $display("LB signed (0xFF) | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=ffffffff");

        // Test 7: LBU - same byte, but unsigned load should be zero extended
        funct3_in = 3'b100; // LBU
        #1;
        $display("LBU unsigned (0xFF) | mem_read_data=%h", mem_read_data_out);
        $display("expect: mem_read_data=000000ff");

        $display("Testbench complete.");
        $finish;

    end
endmodule 

