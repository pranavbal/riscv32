// ex_mem_reg_tb.sv

module ex_mem_reg_tb;
    logic clk, rst;

    // inputs
    logic [31:0] alu_result_in, rs2_data_in, pc_plus_4_in, imm_in;
    logic [4:0] rd_addr_in;
    logic zero_in, reg_write_in, we_in;
    logic [1:0] mem_to_reg_in;

    // outputs
    logic [31:0] alu_result_out, rs2_data_out, pc_plus_4_out, imm_out;
    logic [4:0] rd_addr_out;
    logic zero_out, reg_write_out, we_out;
    logic [1:0] mem_to_reg_out;

    ex_mem_reg uut (
        .clk(clk), .rst(rst),
        .alu_result_in(alu_result_in), .alu_result_out(alu_result_out),
        .rs2_data_in(rs2_data_in), .rs2_data_out(rs2_data_out),
        .pc_plus_4_in(pc_plus_4_in), .pc_plus_4_out(pc_plus_4_out),
        .imm_in(imm_in), .imm_out(imm_out),
        .rd_addr_in(rd_addr_in), .rd_addr_out(rd_addr_out),
        .zero_in(zero_in), .zero_out(zero_out),
        .reg_write_in(reg_write_in), .reg_write_out(reg_write_out),
        .we_in(we_in), .we_out(we_out),
        .mem_to_reg_in(mem_to_reg_in), .mem_to_reg_out(mem_to_reg_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task display_outputs(string label);
        $display("%s | alu=%h rs2d = %h pc4=%h imm=%h rda=%d zero=%b rw=%b we=%b m2r=%b", 
        label, alu_result_out, rs2_data_out, pc_plus_4_out, imm_out, rd_addr_out, zero_out, reg_write_out, we_out, mem_to_reg_out);
    endtask

    initial begin
        // Test 1: reset everything should be zero
        rst = 1;
        alu_result_in = 32'hFFFFFFFF;
        rs2_data_in = 32'hFFFFFFFF;
        pc_plus_4_in = 32'hFFFFFFFF;
        imm_in = 32'hFFFFFFFF;
        rd_addr_in = 5'd31;
        zero_in = 1;
        reg_write_in = 1;
        we_in = 1;
        mem_to_reg_in = 2'b11;
        @(posedge clk); #1;
        display_outputs("After reset");
        $display("expect alu=0 rs2d=0 pc4=0 imm = 0 rda=0 zero=0 rw=0 we=0 m2r=00");

        // Test 2: release the reset, give it real values
        rst = 0;
        alu_result_in = 32'd5;
        rs2_data_in = 32'd0;
        pc_plus_4_in = 32'h0000000C;
        imm_in = 32'd0;
        rd_addr_in = 5'd8;
        zero_in = 0;
        reg_write_in = 1;
        we_in = 0;
        mem_to_reg_in = 2'b00;
        @(posedge clk); #1;
        display_outputs("Cycle 1");
        $display("expect alu=5 rs2d=0 pc4=c imm = 0 rda=8 zero=0 rw=1 we=0 m2r=00");

        // Test 3: driving second set of values
        alu_result_in = 32'd100;
        rs2_data_in = 32'd10;
        pc_plus_4_in = 32'h00000010;
        imm_in = 32'h12345000;
        rd_addr_in = 5'd0;
        zero_in = 0;
        reg_write_in = 0;
        we_in = 1;
        mem_to_reg_in = 2'b00;
        @(posedge clk); #1;
        display_outputs("Cycle 2");
        $display("expect alu=64 rs2d=a pc4=10 imm=12345000 rda=0 zero=0 rw=0 we=1 m2r=00");

        $display("Testbench complete");
        $finish;
    end
endmodule
