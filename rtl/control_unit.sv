// control_unit.sv

module control_unit(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic reg_write,
    output logic we,
    output logic alu_src,
    output logic [3:0] alu_control,
    output logic [1:0] mem_to_reg,
    output logic branch,
    output logic jump,
    output logic auipc,
    output logic jalr

);

always_comb begin
    // reset all output signals to safe values
    reg_write = 0;
    we = 0;
    alu_src = 0;
    alu_control = 0;
    mem_to_reg = 2'b00;
    branch = 0;
    jump = 0;
    auipc = 0;
    jalr = 0;

    case (opcode)
        // R-type - ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
        7'b0110011: begin
            reg_write = 1;
            alu_src = 0;
            case ({funct7, funct3})
                10'b0000000_000: alu_control = 4'b0000; // ADD
                10'b0100000_000: alu_control = 4'b0001; // SUB
                10'b0000000_111: alu_control = 4'b0010; // AND
                10'b0000000_110: alu_control = 4'b0011; // OR
                10'b0000000_100: alu_control = 4'b0100; // XOR
                10'b0000000_001: alu_control = 4'b0101; // SLL
                10'b0000000_101: alu_control = 4'b0110; // SRL
                10'b0100000_101: alu_control = 4'b0111; // SRA
                10'b0000000_010: alu_control = 4'b1000; // SLT
                10'b0000000_011: alu_control = 4'b1001; // SLTU
                default:         alu_control = 4'b0000;
            endcase
        end

        //I-type arithmetic - ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
        7'b0010011: begin
            reg_write = 1;
            alu_src = 1;
            case (funct3)
                3'b000: alu_control = 4'b0000; //ADDI
                3'b111: alu_control = 4'b0010; //ANDI
                3'b110: alu_control = 4'b0011; //ORI
                3'b100: alu_control = 4'b0100; //XORI
                3'b001: alu_control = 4'b0101; //SLLI
                3'b101: alu_control = (funct7[5]) ? 4'b0111 : 4'b0110; //SRAI or SRLI
                3'b010: alu_control = 4'b1000; //SLTI
                3'b011: alu_control = 4'b1001; //SLTIU
                default: alu_control = 4'b0000;
            endcase
        end

        // I-type continued: LOAD - LW, LH, LB, LHU, LBU
        7'b0000011: begin
            reg_write = 1;
            alu_src = 1;
            mem_to_reg = 2'b01;
            alu_control = 4'b0000; // ADD (formula is rs1 + immediate to find memory to load data from)
        end
        
        // Store - SW, SH, SB
        7'b0100011: begin
            we = 1;
            alu_src = 1;
            alu_control = 4'b0000; // ADD(similar to LOAD, rs1 + immediate to find memory to store data to)
        end

        // Branch - BEQ, BNE, BLT, BGE, BLTU, BGEU
        7'b1100011: begin
            alu_src = 0;
            branch  = 1;
            alu_control = 4'b0001; // SUB to compare register values
        end

        // JAL - PC + immediate and then store PC + 4 in rd
        7'b1101111: begin
            reg_write = 1;
            mem_to_reg = 2'b10;
            jump = 1; 
        end

        // JALR - rs1 + immediate and then store PC + 4 in rd
        7'b1100111: begin 
            reg_write = 1;
            alu_src = 1;
            mem_to_reg = 2'b10;
            jump = 1;
            alu_control = 4'b0000; // ADD for rs1 + immediate
            jalr = 1;
        end

        // LUI - load upper immediate
        7'b0110111: begin
            reg_write = 1;
            mem_to_reg = 2'b11;
        end

        // AUIPC
        7'b0010111: begin
            reg_write = 1;
            alu_src = 1;
            alu_control = 4'b0000;
            auipc = 1;
        end

        default: begin
            reg_write   = 0;
            we          = 0;
            alu_src     = 0;
            alu_control = 4'b0000;
            mem_to_reg  = 2'b00;
            branch      = 0;
            jump        = 0;
            auipc       = 0;
            jalr        = 0;
        end
    endcase
end

endmodule

            



 