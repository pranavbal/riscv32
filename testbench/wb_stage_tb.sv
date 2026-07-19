// wb_stage_tb.sv

module wb_stage_tb;
    logic [31:0] alu_result_in;
    logic [31:0] data_read_memory_in;
    logic [31:0] pc_plus_4_in;
    logic [31:0] imm_in;
    logic [1:0] mem_to_reg_in;

    logic [31:0] write_back_data_out;

    wb_stage uut (
        .alu_result_in(alu_result_in),
        .data_read_memory_in(data_read_memory_in),
        .pc_plus_4_in(pc_plus_4_in),
        .imm_in(imm_in),
        .mem_to_reg_in(mem_to_reg_in),
        .write_back_data_out(write_back_data_out)
    );

    initial begin
        alu_result_in = 32'd15;
        data_read_memory_in = 32'd42;
        pc_plus_4_in = 32'd24;
        imm_in = 32'h12345000;

        // Test 1: select alu_result
        mem_to_reg_in = 2'b00;
        #1;
        $display("m2r=00 | wb_data=%0d", write_back_data_out);
        $display("expect: wb_data=15");

        // Test 2: select mem_read_data
        mem_to_reg_in = 2'b01;
        #1;
        $display("m2r=01 | wb_data=%0d", write_back_data_out);
        $display("expect: wb_data=42");

        // Test 3: select pc_plus_4
        mem_to_reg_in = 2'b10;
        #1;
        $display("m2r=10 | wb_data=%0d", write_back_data_out);
        $display("expect: wb_data=24");

        // Test 4: select imm
        mem_to_reg_in = 2'b11;
        #1;
        $display("m2r=11 | wb_data=%h", write_back_data_out);
        $display("expect: wb_data=12345000");

        $display("Testbench complete.");
        $finish;
    end
endmodule