// ex_stage_tb.sv

module ex_stage_tb;
    logic [31:0] pc_current_in;
    logic [31:0] rs1_data_in;
    logic [31:0] rs2_data_in;
    logic [31:0] imm_in;

    logic alu_src_in;
    logic [3:0] alu_control_in;
    logic auipc_in;
    logic jalr_in;
    
    logic [31:0] alu_result_out;
    logic zero_out;
    logic [31:0] branch_target_out;
    logic [31:0] pc_plus_4_out;

    ex_stage uut(
        .pc_current_in(pc_current_in),
        .rs1_data_in(rs1_data_in),
        .rs2_data_in(rs2_data_in),
        .imm_in(imm_in),
        .alu_src_in(alu_src_in),
        .alu_control_in(alu_control_in),
        .auipc_in(auipc_in),
        .jalr_in(jalr_in),
        .alu_result_out(alu_result_out),
        .zero_out(zero_out),
        .branch_target_out(branch_target_out),
        .pc_plus_4_out(pc_plus_4_out)
    );

    initial begin
        // Test 1: R-type ADD - rs1=5, rs2=10
        pc_current_in = 32'h00000004;
        rs1_data_in = 32'd5;
        rs2_data_in = 32'd10;
        imm_in = 32'd0;
        alu_src_in = 0;
        alu_control_in = 4'b0000;
        auipc_in = 0;
        jalr_in = 0;
        #1;
        $display("ADD | alu=%0d zero=%b btgt=%h pc4=%h", alu_result_out, zero_out, branch_target_out, pc_plus_4_out);
        $display("expect: alu=15 zero=0 btgt=00000004 pc4=00000008");

        // Test 2: I-type ADDI - rs1=5, imm=100
        pc_current_in = 32'h00000008;
        rs1_data_in = 32'd5;
        imm_in = 32'd100;
        alu_src_in = 1;
        alu_control_in = 4'b0000;
        auipc_in = 0;
        jalr_in = 0;
        #1;
        $display("ADDI | alu=%0d zero=%b btgt=%h pc4=%h", alu_result_out, zero_out, branch_target_out, pc_plus_4_out);
        $display("expect: alu=105 zero=0 btgt=0000006c pc4=0000000c");

        // Test 3: B-type BEQ - rs1=5, rs2=5 
        pc_current_in = 32'h0000000C;
        rs1_data_in = 32'd5;
        rs2_data_in = 32'd5;
        alu_src_in = 0;
        alu_control_in = 4'b0001;
        imm_in = 32'd8;
        auipc_in = 0;
        jalr_in = 0;
        #1;
        $display("BEQ | alu=%0d zero=%b btgt=%h pc4=%h", alu_result_out, zero_out, branch_target_out, pc_plus_4_out);
        $display("expect: alu=0 zero=1 btgt=00000014 pc4=00000010");

        // Test 4: AUIPC - pc=0x100, imm=0x2000 -> alu should compute be pc+imm
        pc_current_in = 32'h00000100;
        rs1_data_in = 32'd999;          // this num should be ignored
        imm_in = 32'h00002000;
        alu_src_in = 1;
        alu_control_in = 4'b0000;
        auipc_in = 1;
        jalr_in = 0;
        #1;
        $display("AUIPC | alu=%h zero=%b ", alu_result_out, zero_out);
        $display("expect: alu=00002100 zero=0");

        // Test 5: JALR - rs1=0x200, imm=0x10 -> branch target should be rs1+imm
        pc_current_in = 32'h00000050;
        rs1_data_in = 32'h00000200;          // this num should be ignored
        imm_in = 32'h00000010;
        auipc_in = 0;
        jalr_in = 1;
        #1;
        $display("JALR | btgt=%h", branch_target_out);
        $display("expect: btgt=00000210");


        $display("Testbench complete.");
        $finish;
    end
endmodule


