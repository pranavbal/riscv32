// control_unit_tb.sv

module control_unit_tb;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic reg_write;
    logic we;
    logic alu_src;
    logic [3:0] alu_control;
    logic [1:0] mem_to_reg;
    logic branch;
    logic jump;
    logic auipc;
    logic jalr;

    control_unit uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .we(we),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .auipc(auipc),
        .jalr(jalr)
    );

    initial begin
        // R-type ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 0 0000 00 0 0 0 0");

        // R-type SUB
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 0 0001 00 0 0 0 0");

        // I-type ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 1 0000 00 0 0 0 0");

        // I-type extended (LOAD LW)
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 1 0000 01 0 0 0 0");

        // S-type SW
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 0 1 1 0000 0 0 0 0 0");

        // B-type BEQ
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 0 0 0 0001 0 1 0 0 0");

        // J-type JAL
        opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 0 0000 10 0 1 0 0");

         // U-type LUI
        opcode = 7'b0110111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 0 0000 11 0 0 0 0");

        // JALR (I - type)
        opcode = 7'b1100111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 1 0000 10 0 1 0 1");

        // AUIPC (U - type)
        opcode = 7'b0010111; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADD | rw=%b we=%b asrc=%b aluctrl=%b m2r=%b br=%b jmp=%b au=%b jr=%b", reg_write, we, alu_src, alu_control, mem_to_reg, branch, jump, auipc, jalr);
        $display("expect: 1 0 1 0000 00 0 0 1 0");

        $display("Testbench complete.");
        $finish;

    end
endmodule