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

    typedef enum {K_R, K_I, K_SHIFT, K_LUI, K_AUIPC, K_LOAD, K_STORE, K_BRANCH} instr_kind_e;

    rand instr_kind_e kind;
    rand bit [2:0] funct3;
    rand bit alt; // 1 is SUB/SRA/SRAI (funct7 = 0100000)
    rand bit [4:0] rd, rs1, rs2;
    rand bit [11:0] imm12;
    rand bit [4:0] shamt;
    rand bit [19:0] imm20;
    rand bit [12:0] boff;

    // to make sure instructions depend on each other, only using 8 registers
    constraint c_regs { 
        rd inside {[0:8]}; 
        rs1 inside {[0:8]}; 
        rs2 inside {[0:8]}; 
    }
    
    // controls the distribution of different types of instructions
    // constraint c_kind { 
    //    kind dist {K_R := 30, K_I := 20, K_SHIFT := 10, K_LUI := 5, K_AUIPC := 5, K_LOAD := 20, K_STORE := 10};
    //}

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

    // loads and stores: base is always x0, offset is range
    constraint c_mem {
        (kind == K_LOAD)  -> funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
        (kind == K_STORE) -> funct3 inside {3'b000, 3'b001, 3'b010};
        (kind == K_LOAD || kind == K_STORE) -> rs1 == 0;
        (kind == K_LOAD || kind == K_STORE) -> alt == 0;
        (kind == K_LOAD || kind == K_STORE) -> imm12 inside {[0:32]};
        (kind == K_LOAD || kind == K_STORE) -> (funct3[1:0] == 2'b10) -> imm12[1:0] == 2'b00;
        (kind == K_LOAD || kind == K_STORE) -> (funct3[1:0] == 2'b01) -> imm12[0] == 1'b0;
    }

    constraint c_branch {
        (kind == K_BRANCH) -> funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
        (kind == K_BRANCH) -> alt == 0;
        (kind == K_BRANCH) -> boff inside {[4:16]};
        (kind == K_BRANCH) -> boff[1:0] == 2'b00;
    }


    constraint c_order { solve kind before funct3, alt; solve funct3 before imm12; }
    
    // pack random fields into 32-bit instruction word
    function logic [31:0] to_word();
        logic [6:0] f7;
        f7 = alt ? 7'b0100000 : 7'b0000000;
        case (kind)
        K_R: to_word = {f7, rs2, rs1, funct3, rd, 7'b0110011};
        K_I: to_word = {imm12, rs1, funct3, rd, 7'b0010011};
        K_LOAD:  to_word = {imm12, rs1, funct3, rd, 7'b0000011};
        K_STORE: to_word = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], 7'b0100011};
        K_SHIFT: to_word = {f7, shamt, rs1, funct3, rd, 7'b0010011};
        K_LUI: to_word = {imm20, rd, 7'b0110111};
        K_AUIPC: to_word = {imm20, rd, 7'b0010111};
        K_BRANCH: to_word = {boff[12], boff[10:5], rs2, rs1, funct3, boff[4:1], boff[11], 7'b1100011};
        default: to_word = 32'h00000013;
        endcase
    endfunction


endclass