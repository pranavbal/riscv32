// instruction_transaction.sv
// Data container representing an instruction as it flows through verification environment
// split in two: stimulus and observation

class instruction_transaction;
    // stimulus - filled in by sequences/driver
    logic [31:0] instruction;
    logic [31:0] pc;

    // observed fields - filled in by monitor
    logic [4:0] rd_addr;
    logic [31:0] write_data;
    logic        reg_write;

    // ------ random instruction generation-----------------

    typedef enum {K_R, K_I, K_SHIFT, K_LUI, K_AUIPC} instr_kind_e;

    rand instr_kind_e kind;
    rand bit [2:0] funct3;
    rand bit alt; // 1 is SUB/SRA/SRAI (funct7 = 0100000)
    rand bit [4:0] rd, rs1, rs2;
    rand bit [11:0] imm12;
    rand bit [4:0] shamt;
    rand bit [19:0] imm20;

    // to make sure instructions depend on each other, only using 8 registers
    constraint c_regs { 
        rd inside {[0:8]}; 
        rs1 inside {[0:8]}; 
        rs2 inside {[0:8]}; 
    }
    
    // controls the distribution of different types of instructions
    constraint c_kind { 
        kind dist {K_R := 40, K_I := 30, K_SHIFT := 10, K_LUI := 10, K_AUIPC := 10};
    }

    // for SUB (000) and SRA(101)
    constraint c_r {
        (kind == K_R && !(funct3 inside {3'b000, 3'b101})) -> alt == 0;
    }

    // I-type ALU: shifts are different 
    constraint c_i { 
        (kind == K_I) -> !(funct3 inside {3'b001, 3'b101});
    }

    // shift immediates: SLLI (001, alt must be 0), SRLI/SRAI (101)
    constraint c_shift {
        (kind == K_SHIFT) -> funct3 inside {3'b001, 3'b101};
        (kind == K_SHIFT && funct3 == 3'b001) -> alt == 0;
    }

    constraint c_order { solve kind before funct3, alt; }
    
    // pack random fields into 32-bit instruction word
    function logic [31:0] to_word();
        logic [6:0] f7;
        f7 = alt ? 7'b0100000 : 7'b0000000;
        case (kind)
        K_R: to_word = {f7, rs2, rs1, funct3, rd, 7'b0110011};
        K_I: to_word = {imm12, rs1, funct3, rd, 7'b0010011};
        K_SHIFT: to_word = {f7, shamt, rs1, funct3, rd, 7'b0010011};
        K_LUI: to_word = {imm20, rd, 7'b0110111};
        K_AUIPC: to_word = {imm20, rd, 7'b0010111};
        default: to_word = 32'h00000013;
        endcase
    endfunction


endclass