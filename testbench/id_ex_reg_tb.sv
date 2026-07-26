// id_ex_reg_tb.sv

module id_ex_reg_tb;
    logic clk, rst;

    // inputs
    logic [31:0] pc_current_in;
    logic [31:0] rs1_data_in, rs2_data_in, imm_in;
    logic [4:0] rs1_addr_in, rs2_addr_in, rd_addr_in;
    logic [2:0] funct3_in;
    logic reg_write_in, we_in, alu_src_in, branch_in, jump_in, auipc_in, jalr_in;
    logic [3:0] alu_control_in;
    logic [1:0] mem_to_reg_in;

    //outputs 
    logic [31:0] pc_current_out;
    logic [31:0] rs1_data_out, rs2_data_out, imm_out;
    logic [4:0] rs1_addr_out, rs2_addr_out, rd_addr_out;
    logic [2:0] funct3_out;
    logic reg_write_out, we_out, alu_src_out, branch_out, jump_out, auipc_out, jalr_out;
    logic [3:0] alu_control_out;
    logic [1:0] mem_to_reg_out;

    id_ex_reg uut (
        .clk(clk), 
        .rst(rst),
        .pc_current_in(pc_current_in), .pc_current_out(pc_current_out),
        .rs1_data_in(rs1_data_in), .rs1_data_out(rs1_data_out),
        .rs2_data_in(rs2_data_in), .rs2_data_out(rs2_data_out),
        .imm_in(imm_in), .imm_out(imm_out),
        .rs1_addr_in(rs1_addr_in), .rs1_addr_out(rs1_addr_out),
        .rs2_addr_in(rs2_addr_in), .rs2_addr_out(rs2_addr_out),
        .rd_addr_in(rd_addr_in), .rd_addr_out(rd_addr_out),
        .funct3_in(funct3_in), .funct3_out(funct3_out),
        .reg_write_in(reg_write_in), .reg_write_out(reg_write_out), 
        .we_in(we_in), .we_out(we_out),
        .alu_src_in(alu_src_in), .alu_src_out(alu_src_out),
        .alu_control_in(alu_control_in), .alu_control_out(alu_control_out),
        .mem_to_reg_in(mem_to_reg_in), .mem_to_reg_out(mem_to_reg_out),
        .branch_in(branch_in), .branch_out(branch_out),
        .jump_in(jump_in), .jump_out(jump_out),
        .auipc_in(auipc_in), .auipc_out(auipc_out),
        .jalr_in(jalr_in), .jalr_out(jalr_out)
    
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task display_outputs(string label);
        $display("%s | pc=%h rs1d=%h rs2d=%h imm=%h rs1a=%d rs2a=%d rda=%d f3=%b rw=%b we=%b asr=%b actrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b ", 
                label, pc_current_out, rs1_data_out, rs2_data_out, imm_out, rs1_addr_out, rs2_addr_out, rd_addr_out, funct3_out, reg_write_out, 
                we_out, alu_src_out, alu_control_out, mem_to_reg_out, branch_out, jump_out, auipc_out, jalr_out);
    endtask

    initial begin
        // Test 1: reset everything; zero everything 
        rst = 1;
        pc_current_in = 32'hFFFFFFFF;
        rs1_data_in = 32'hFFFFFFFF;
        rs2_data_in = 32'hFFFFFFFF;
        imm_in = 32'hFFFFFFFF;
        rs1_addr_in = 5'd31;
        rs2_addr_in = 5'd31;
        rd_addr_in = 5'd31;
        funct3_in = 3'b111;
        reg_write_in = 1;
        we_in = 1;
        alu_src_in = 1;
        alu_control_in = 4'b1111;
        mem_to_reg_in = 2'b11;
        branch_in = 1;
        jump_in = 1;
        auipc_in = 1;
        jalr_in = 1;
        @(posedge clk); #1;
        display_outputs("After reset");
        $display("expect: pc=0 rs1d=0 rs2d=0 imm=0 rs1a=0 rs2a=0 rda=0 f3=000 rw=0 we=0 asrc=0 actrl=0 m2r=0 br=0 jmp=0 au=0 jr=0");

        // Test 2: release the reset and drive values (ADD x3, x1, x2)
        rst = 0;
        pc_current_in = 32'h00000004;
        rs1_data_in = 32'd5;
        rs2_data_in = 32'd10;
        imm_in = 32'd0;
        rs1_addr_in = 5'd1;
        rs2_addr_in = 5'd2;
        rd_addr_in = 5'd3;
        funct3_in = 3'b000;
        reg_write_in = 1;
        we_in = 0;
        alu_src_in = 0;
        alu_control_in = 4'b0000;
        mem_to_reg_in = 2'b00;
        branch_in = 0;
        jump_in = 0;
        auipc_in = 0;
        jalr_in = 0;
        @(posedge clk); #1;
        display_outputs("Cycle 1");
        $display("expect: pc=4 rs1d=5 rs2d=a imm=0 rs1a=1 rs2a=2 rda=3 f3=000 rw=1 we=0 asrc=0 actrl=0 m2r=00 br=0 jmp=0 au=0 jr=0");


        // Test 3: drive another set of values this time LW x5, 0(x1)   
        pc_current_in = 32'h00000008;
        rs1_data_in = 32'd20;
        rs2_data_in = 32'd0;
        imm_in = 32'd0;
        rs1_addr_in = 5'd1;
        rs2_addr_in = 5'd0;
        rd_addr_in = 5'd5;
        funct3_in = 3'b010;
        reg_write_in = 1;
        we_in = 0;
        alu_src_in = 1;
        alu_control_in = 4'b0000;
        mem_to_reg_in = 2'b01;
        branch_in = 0;
        jump_in = 0;
        auipc_in = 0;
        jalr_in = 0;
        @(posedge clk); #1;
        display_outputs("Cycle 2");
        $display("expect: pc=8 rs1d=14 rs2d=0 imm=0 rs1a=1 rs2a=0 rda=5 f3=010 rw=1 we=0 asrc=1 actrl=0 m2r=01 br=0 jmp=0 au=0 jr=0");

        // Test 4: drive AUIPC   
        pc_current_in = 32'h00000100;
        rs1_data_in = 32'd0;
        rs2_data_in = 32'd0;
        imm_in = 32'h00002000;
        rs1_addr_in = 5'd0;
        rs2_addr_in = 5'd0;
        rd_addr_in = 5'd7;
        funct3_in = 3'b000;
        reg_write_in = 1;
        we_in = 0;
        alu_src_in = 1;
        alu_control_in = 4'b0000;
        mem_to_reg_in = 2'b00;
        branch_in = 0;
        jump_in = 0;
        auipc_in = 1;
        jalr_in = 0;
        @(posedge clk); #1;
        display_outputs("Cycle 3");
        $display("expect: pc=100 rs1d=0 rs2d=0 imm=2000 rs1a=0 rs2a=0 rda=7 f3=000 rw=1 we=0 asrc=1 actrl=0 m2r=00 br=0 jmp=0 au=1 jr=0");

        // Test 5: drive JALR   
        pc_current_in = 32'h00000050;
        rs1_data_in = 32'h00000200;
        rs2_data_in = 32'd0;
        imm_in = 32'h00000010;
        rs1_addr_in = 5'd0;
        rs2_addr_in = 5'd0;
        rd_addr_in = 5'd8;
        funct3_in = 3'b000;
        reg_write_in = 1;
        we_in = 1;
        alu_src_in = 1;
        alu_control_in = 4'b0000;
        mem_to_reg_in = 2'b10;
        branch_in = 0;
        jump_in = 1;
        auipc_in = 0;
        jalr_in = 1;
        @(posedge clk); #1;
        display_outputs("Cycle 4");
        $display("expect: pc=50 rs1d=200 rs2d=0 imm=10 rs1a=0 rs2a=0 rda=8 f3=000 rw=1 we=1 asrc=1 actrl=0 m2r=10 br=0 jmp=1 au=0 jr=1");
        
        $display("Testbench complete.");
        $finish;

    end
endmodule