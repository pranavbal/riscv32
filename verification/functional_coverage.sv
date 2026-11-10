// functional_coverage.sv
// tracks which RV32I instructions/behaviors have been exercised

class functional_coverage;

    logic [31:0] current_instr;
    logic [6:0]  current_opcode;
    logic [2:0]  current_funct3;
    logic        current_alt;       // instruction[30]: SUB/SRA/SRAI
    logic        current_imm_neg;   // instruction[31]: negative offset
    logic        current_rs1_zero;  // base/source register is x0
    logic        current_rd_zero;   // destination is x0
    logic        current_bit20;     // JALR offset bit 0

    // one bin per opcode
    covergroup instruction_coverage;
        coverpoint current_opcode {
            bins r_type = {7'b0110011};
            bins i_type = {7'b0010011};
            bins load   = {7'b0000011};
            bins store  = {7'b0100011};
            bins branch = {7'b1100011};
            bins lui    = {7'b0110111};
            bins auipc  = {7'b0010111};
            bins jal    = {7'b1101111};
            bins jalr   = {7'b1100111};
            bins misc   = {7'b0001111, 7'b1110011};
        }
    endgroup

    // which variant of each instruction was exercised
    covergroup detail_coverage;
        cp_r_op: coverpoint {current_alt, current_funct3} iff (current_opcode == 7'b0110011) {
            bins add    = {4'b0000};
            bins sub    = {4'b1000};
            bins sll    = {4'b0001};
            bins slt    = {4'b0010};
            bins sltu   = {4'b0011};
            bins op_xor = {4'b0100};
            bins srl    = {4'b0101};
            bins sra    = {4'b1101};
            bins op_or  = {4'b0110};
            bins op_and = {4'b0111};
        }
        cp_i_op: coverpoint current_funct3 iff (current_opcode == 7'b0010011) {
            bins addi  = {3'b000};
            bins slli  = {3'b001};
            bins slti  = {3'b010};
            bins sltiu = {3'b011};
            bins xori  = {3'b100};
            bins sri   = {3'b101};
            bins ori   = {3'b110};
            bins andi  = {3'b111};
        }
        cp_sr: coverpoint current_alt iff (current_opcode == 7'b0010011 && current_funct3 == 3'b101) {
            bins srli = {1'b0};
            bins srai = {1'b1};
        }
        cp_load_op: coverpoint current_funct3 iff (current_opcode == 7'b0000011) {
            bins lb  = {3'b000};
            bins lh  = {3'b001};
            bins lw  = {3'b010};
            bins lbu = {3'b100};
            bins lhu = {3'b101};
        }
        cp_store_op: coverpoint current_funct3 iff (current_opcode == 7'b0100011) {
            bins sb = {3'b000};
            bins sh = {3'b001};
            bins sw = {3'b010};
        }
        cp_branch_op: coverpoint current_funct3 iff (current_opcode == 7'b1100011) {
            bins beq  = {3'b000};
            bins bne  = {3'b001};
            bins blt  = {3'b100};
            bins bge  = {3'b101};
            bins bltu = {3'b110};
            bins bgeu = {3'b111};
        }
        // loads/stores: x0 base vs register base, positive vs negative offset
        cp_mem_base: coverpoint current_rs1_zero iff (current_opcode == 7'b0000011 || current_opcode == 7'b0100011) {
            bins x0_base  = {1'b1};
            bins reg_base = {1'b0};
        }
        cp_mem_off: coverpoint current_imm_neg iff (current_opcode == 7'b0000011 || current_opcode == 7'b0100011) {
            bins pos_off = {1'b0};
            bins neg_off = {1'b1};
        }
        x_mem: cross cp_mem_base, cp_mem_off {
            // x0 base + negative offset = negative address, never generated on purpose
            ignore_bins impossible = binsof(cp_mem_base.x0_base) && binsof(cp_mem_off.neg_off);
        }
        // jumps
        cp_jal_link: coverpoint current_rd_zero iff (current_opcode == 7'b1101111) {
            bins link    = {1'b0};
            bins no_link = {1'b1};
        }
        cp_jalr_bit0: coverpoint current_bit20 iff (current_opcode == 7'b1100111) {
            bins even_off = {1'b0};
            bins odd_off  = {1'b1};
        }
        // FENCE / ECALL / EBREAK
        cp_misc: coverpoint current_instr {
            bins fence  = {32'h0FF0000F};
            bins ecall  = {32'h00000073};
            bins ebreak = {32'h00100073};
        }
        // writes to x0 (must be ignored) vs a real register
        cp_rd0: coverpoint current_rd_zero iff (current_opcode == 7'b0110011 || current_opcode == 7'b0010011 || current_opcode == 7'b0000011) {
            bins writes_x0  = {1'b1};
            bins writes_reg = {1'b0};
        }
    endgroup

    function new();
        instruction_coverage = new();
        detail_coverage = new();
    endfunction

    function void sample(logic [31:0] instruction);
        current_instr    = instruction;
        current_opcode   = instruction[6:0];
        current_funct3   = instruction[14:12];
        current_alt      = instruction[30];
        current_imm_neg  = instruction[31];
        current_rs1_zero = (instruction[19:15] == 5'b0);
        current_rd_zero  = (instruction[11:7] == 5'b0);
        current_bit20    = instruction[20];
        instruction_coverage.sample();
        detail_coverage.sample();
    endfunction

    // prints the coverage of each checklist, so low ones are easy to spot
    function void report_detail();
        $display("  cp_r_op       %0.1f%%", detail_coverage.cp_r_op.get_coverage());
        $display("  cp_i_op       %0.1f%%", detail_coverage.cp_i_op.get_coverage());
        $display("  cp_sr         %0.1f%%", detail_coverage.cp_sr.get_coverage());
        $display("  cp_load_op    %0.1f%%", detail_coverage.cp_load_op.get_coverage());
        $display("  cp_store_op   %0.1f%%", detail_coverage.cp_store_op.get_coverage());
        $display("  cp_branch_op  %0.1f%%", detail_coverage.cp_branch_op.get_coverage());
        $display("  cp_mem_base   %0.1f%%", detail_coverage.cp_mem_base.get_coverage());
        $display("  cp_mem_off    %0.1f%%", detail_coverage.cp_mem_off.get_coverage());
        $display("  x_mem         %0.1f%%", detail_coverage.x_mem.get_coverage());
        $display("  cp_jal_link   %0.1f%%", detail_coverage.cp_jal_link.get_coverage());
        $display("  cp_jalr_bit0  %0.1f%%", detail_coverage.cp_jalr_bit0.get_coverage());
        $display("  cp_misc       %0.1f%%", detail_coverage.cp_misc.get_coverage());
        $display("  cp_rd0        %0.1f%%", detail_coverage.cp_rd0.get_coverage());
    endfunction

endclass