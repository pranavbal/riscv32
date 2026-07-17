// mem_wb_reg_tb.sv

module mem_wb_reg_tb;
    logic clk, rst;

    // inputs
    logic [31:0] alu_result_in, mem_read_data_in, pc_plus_4_in, imm_in;
    logic [4:0] rd_addr_in;
    logic reg_write_in;
    logic [1:0] mem_to_reg_in;

    // outputs
    logic [31:0] alu_result_out, mem_read_data_out, pc_plus_4_out, imm_out;
    logic [4:0] rd_addr_out;
    logic reg_write_out;
    logic [1:0] mem_to_reg_out;

    mem_wb_reg uut (
        .clk(clk), .rst(rst),
        .alu_result_in(alu_result_in), .alu_result_out(alu_result_out),
        .mem_read_data_in(mem_read_data_in), .mem_read_data_out(mem_read_data_out),
        .pc_plus_4_in(pc_plus_4_in), .pc_plus_4_out(pc_plus_4_out),
        .imm_in(imm_in), .imm_out(imm_out),
        .rd_addr_in(rd_addr_in), .rd_addr_out(rd_addr_out),
        .reg_write_in(reg_write_in), .reg_write_out(reg_write_out),
        .mem_to_reg_in(mem_to_reg_in), .mem_to_reg_out(mem_to_reg_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task display_outputs(string label);
        $display("%s | alu=%h mrd=%h pc4=%h imm=%h rda=%d rw=%b m2r=%b",
        label, alu_result_out, mem_read_data_out, pc_plus_4_out, imm_out, rd_addr_out, reg_write_out, mem_to_reg_out);
    endtask 

    initial begin
        // Test 1: reset everything to zero
        rst = 1;
        alu_result_in = 32'hFFFFFFFF;
        mem_read_data_in = 32'hFFFFFFFF;
        pc_plus_4_in = 32'hFFFFFFFF;
        imm_in = 32'hFFFFFFFF;
        rd_addr_in = 5'd31;
        reg_write_in = 1;
        mem_to_reg_in = 2'b11;
        @(posedge clk); #1;
        display_outputs("After reset");
        $display("expect: alu=0 mrd=0 pc4=0 imm=0 rda=0 rw=0 m2r=00");

        // Test 2: release the reset and drive real values
        rst = 0;
        alu_result_in = 32'd5;
        mem_read_data_in = 32'd0;
        pc_plus_4_in = 32'h0000000C;
        imm_in = 32'd0;
        rd_addr_in = 5'd8;
        reg_write_in = 1;
        mem_to_reg_in = 2'b00;
        @(posedge clk); #1;
        display_outputs("Cycle 1");
        $display("expect: alu=5 mrd=0 pc4=c imm=0 rda=8 rw=1 m2r=00");

        // Test 3: drive another set of values 
        alu_result_in = 32'd0;
        mem_read_data_in = 32'd0;
        pc_plus_4_in = 32'h00000010;
        imm_in = 32'h12345000;
        rd_addr_in = 5'd10;
        reg_write_in = 1;
        mem_to_reg_in = 2'b11;
        @(posedge clk); #1;
        display_outputs("Cycle 2");
        $display("expect: alu=0 mrd=0 pc4=10 imm=12345000 rda=10 rw=1 m2r=11");

        $display("Testbench complete.");
        $finish;
    end
endmodule
