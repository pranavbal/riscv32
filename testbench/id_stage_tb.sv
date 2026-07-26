// id_stage_tb.sv

module id_stage_tb;
    logic clk;
    logic rst;
    logic [31:0] instruction_in;

    // write-back inputs for register file
    logic [31:0] wb_data;
    logic [4:0] wb_rd_addr;
    logic       wb_reg_write;


    //outputs
    logic [31:0] rs1_data_out;
    logic [31:0] rs2_data_out;
    logic [4:0] rs1_addr_out;
    logic [4:0] rs2_addr_out;
    logic [4:0] rd_addr_out;
    logic [31:0] imm_out;
    logic [2:0] funct3_out;
    logic auipc_out;
    logic jalr_out;

    // control unit signals
    logic reg_write_out;
    logic we_out;
    logic alu_src_out;
    logic [3:0] alu_control_out;
    logic [1:0] mem_to_reg_out;
    logic branch_out;
    logic jump_out;

    id_stage uut(
        .clk(clk), .rst(rst),
        .instruction_in(instruction_in),
        .rs1_data_out(rs1_data_out), .rs2_data_out(rs2_data_out),
        .rs1_addr_out(rs1_addr_out), .rs2_addr_out(rs2_addr_out), .rd_addr_out(rd_addr_out),
        .imm_out(imm_out),
        .auipc_out(auipc_out), .jalr_out(jalr_out),
        .reg_write_out(reg_write_out), .we_out(we_out), .alu_src_out(alu_src_out),
        .alu_control_out(alu_control_out), .mem_to_reg_out(mem_to_reg_out),
        .branch_out(branch_out), .jump_out(jump_out),
        .funct3_out(funct3_out),
        .wb_data(wb_data), .wb_rd_addr(wb_rd_addr), .wb_reg_write(wb_reg_write)

    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // reset doesn't do much for id_stage it only resets the 32 registers in the reg_file
        rst = 1;
        instruction_in = 32'h00000000;
        wb_data = 32'h0;
        wb_rd_addr = 5'd0;
        wb_reg_write = 0;
        @(posedge clk); #1;

        rst = 0;

        // Drive data into register_file x1 from wb
        wb_data = 32'd5;
        wb_rd_addr = 5'd1;
        wb_reg_write = 1;
        @(posedge clk); #1;

        wb_reg_write = 0;

        // drive data into register file x2 from wb
        wb_data = 32'd10;
        wb_rd_addr = 5'd2;
        wb_reg_write = 1;
        @(posedge clk); #1;

        wb_reg_write = 0;

        // now drive real instructions to use those registers
        // Test 1: R-type - ADD x3, x1, x2 (funct3 = 000)
        instruction_in = 32'h002081B3;
        #1;
        $display("ADD | rs1a=%d rs2a=%d rs1d=%h rs2d=%h rda=%h rw=%h asrc=%b actrl=%h m2r=%b f3=%b au=%b jr=%b",
        rs1_addr_out, rs2_addr_out, rs1_data_out, rs2_data_out, rd_addr_out, reg_write_out, alu_src_out, alu_control_out, mem_to_reg_out, funct3_out, auipc_out, jalr_out);
        $display("expect: rs1a=1 rs2a=2 rs1d=5 rs2d=10 rda=3 rw=1 asrc=0 actrl=0000 m2r=00 f3=000 au=0 jr=0");

        // Test 2: I-type - ADDI x4, x1, 100 (funct3 = 000)
        instruction_in = 32'h06408213;
        #1;
        $display("ADDI | rs1a=%d rs1d=%h rda=%h imm=%0d rw=%h asrc=%b actrl=%h m2r=%b f3=%b au=%b jr=%b",
        rs1_addr_out, rs1_data_out, rd_addr_out, imm_out, reg_write_out, alu_src_out, alu_control_out, mem_to_reg_out, funct3_out, auipc_out, jalr_out);
        $display("expect: rs1a=1 rs1d=5 rda=4 imm=100 rw=1 asrc=1 actrl=0000 m2r=00 f3=000 au=0 jr=0");

        // Test 3: I-type - LW x5, 8(x1) (funct3 = 010)
        instruction_in = 32'h0080A283;
        #1;
        $display("LW | rs1a=%d rs1d=%h rda=%h imm=%0d rw=%h asrc=%b actrl=%h m2r=%b f3=%b au=%b jr=%b",
        rs1_addr_out, rs1_data_out, rd_addr_out, imm_out, reg_write_out, alu_src_out, alu_control_out, mem_to_reg_out, funct3_out, auipc_out, jalr_out);
        $display("expect: rs1a=1 rs1d=5 rda=5 imm=8 rw=1 asrc=1 actrl=0000 m2r=01 f3=010 au=0 jr=0");

        // Test 4: AUIPC x5, 0
        instruction_in = 32'h00000297;
        #1;
        $display("rda=%h rw=%h asrc=%b actrl=%h m2r=%b au=%b jr=%b", rd_addr_out, reg_write_out, alu_src_out, alu_control_out, mem_to_reg_out, auipc_out, jalr_out);
        $display("expect: rda=5 rw=1 asrc=1 actrl=0000 m2r=00 au=1 jr=0");

        // Test 5: JALR x8, 4(x1)
        instruction_in = 32'h00408467;
        #1;
        $display("rda=%h rs1a=%d rw=%h asrc=%b actrl=%h m2r=%b jr=%b au=%b", rd_addr_out, rs1_addr_out, reg_write_out, alu_src_out, alu_control_out, mem_to_reg_out, jalr_out, auipc_out);
        $display("expect: rda=8 rs1a=1 rw=1 asrc=1 actrl=0000 m2r=10 jr=1 au=0");   

        $display("Testbench complete.");
        $finish;
    end
endmodule
