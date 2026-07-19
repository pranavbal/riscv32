// mem_stage_tb.sv

module mem_stage_tb;
    logic clk;
    logic we_in;
    logic [31:0] alu_result_in;
    logic [31:0] rs2_data_in;
    logic [31:0] mem_read_data_out;

    mem_stage uut(
        .clk(clk),
        .we_in(we_in),
        .alu_result_in(alu_result_in),
        .rs2_data_in(rs2_data_in),
        .mem_read_data_out(mem_read_data_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Test 1: store 77 to address 8
        we_in = 1;
        alu_result_in = 32'd8;
        rs2_data_in = 32'd77;
        @(posedge clk); #1;

        // Test 2: load - read back address 8
        we_in = 0;
        alu_result_in = 32'd8;
        rs2_data_in = 32'd0;
        #1;
        $display("Load after store | mem_read_data=%0d", mem_read_data_out);
        $display("expect: mem_read_data=77");

        // Test 3: Load from an untouched addr - mem_read should be 0
        we_in = 0;
        alu_result_in = 32'd20;
        #1;
        $display("Load untouched addr | mem_read_data=%0d", mem_read_data_out);
        $display("expect: mem_read_data=0");

        $display("Testbench complete.");
        $finish;
    end
endmodule