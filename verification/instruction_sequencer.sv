// instruction_sequencer.sv
// generates a stream of instruction_transaction objections from a fixed instruction list (for now)


class kind_picker;
    rand int unsigned pick;
    rand int unsigned idx;
    rand int unsigned jmp;
    constraint c_pick { pick < 100; }
    constraint c_idx  { idx < 60; }
    constraint c_jmp { jmp < 12; }
endclass


class instruction_sequencer;

    logic [31:0] instr_list [$];

    function new();
    // JALR BIT-0 TEST (active)
        instr_list.push_back(32'h01100093); // ADDI  x1,x0,17   x1 = 17
        instr_list.push_back(32'h00008167); // JALR  x2,0(x1)   x2 = 8, target = 17 & ~1 = 16
      instr_list.push_back(32'h06300493); // ADDI  x9,x0,99   skipped
        instr_list.push_back(32'h06200493); // ADDI  x9,x0,98   skipped
         instr_list.push_back(32'h00000197); // AUIPC x3,0       x3 = 16
     instr_list.push_back(32'h00700213); // ADDI  x4,x0,7    x4 = 7
        instr_list.push_back(32'h00000013); // NOP
       instr_list.push_back(32'h00000013); // NOP
        instr_list.push_back(32'h00000013); // NOP
      instr_list.push_back(32'h00000013); // NOP

    // ORIGINAL PROGRAM (inactive)
    //   instr_list.push_back(32'h00500093); // ADDI x1,x0,5    x1 = 5
      //  instr_list.push_back(32'h00A00113); // ADDI x2,x0,10   x2 = 10
      //  instr_list.push_back(32'h002081B3); // ADD  x3,x1,x2   x3 = 15
     //   instr_list.push_back(32'h40118233); // SUB  x4,x3,x1   x4 = 10
     //  instr_list.push_back(32'h00402023); // SW   x4,0(x0)   mem[0] = 10
     //   instr_list.push_back(32'h00002283); // LW   x5,0(x0)   x5 = 10
      //  instr_list.push_back(32'h00128333); // ADD  x6,x5,x1   x6 = 15
      //  instr_list.push_back(32'h00108463); // BEQ  x1,x1,+8   taken
      //  instr_list.push_back(32'h06300393); // ADDI x7,x0,99   skipped
     //  instr_list.push_back(32'h04D00413); // ADDI x8,x0,77   x8 = 77

        // LUI (INACTIVE)
      //  instr_list.push_back(32'h000012B7); // LUI  x5,0x1     x5  = 4096
      //   instr_list.push_back(32'h00128313); // ADDI x6,x5,1    x6  = 4097 (EX/MEM forward from LUI)
      //   instr_list.push_back(32'h00000013); // NOP             no write
      //   instr_list.push_back(32'h00728013); // ADDI x0,x5,7    no write (x0)
      //   instr_list.push_back(32'h005003B3); // ADD  x7,x0,x5   x7  = 4096 (x0 must read 0)
       //  instr_list.push_back(32'h00002437); // LUI  x8,0x2     x8  = 8192
      //   instr_list.push_back(32'h00300493); // ADDI x9,x0,3    x9  = 3
     //    instr_list.push_back(32'h00940533); // ADD  x10,x8,x9  x10 = 8195 (MEM/WB forward from LUI)
      //   instr_list.push_back(32'h00030593); // ADDI x11,x6,0   x11 = 4097
      //   instr_list.push_back(32'h00000013); // NOP             no write
    endfunction

    
    function void load_random(int n, int seed);
      instruction_transaction tx;
      kind_picker kp;
      logic [4:0] r;
      instruction_transaction::instr_kind_e k;
      int pick;
      bit [2:0] f3;
      int total;  
      int pos;     
      int maxk;    
      int bk;     
      instruction_transaction::instr_kind_e k2;
      bit [4:0] rt;
      int off;
      bit is_tgt [0:4095]; 
      bit [11:0] bv; 
      bit alt_v;
      int br_cnt;
      int i_cnt;
      int sh_cnt;
      int bm;
      bit bfall;
      bit in_shadow [0:4095];
      instr_list.delete();
      br_cnt = 0;
      i_cnt  = 0;
      sh_cnt = 0;
      foreach (is_tgt[i]) is_tgt[i] = 1'b0;
      foreach (in_shadow[i]) in_shadow[i] = 1'b0;
      tx = new();
      tx.srandom(seed);
      kp = new();
      kp.srandom(seed);

      // make the first 8 instructions ADDI to put random value into registers
      for (int i = 1; i <= 8; i++) begin
        if (!tx.randomize()) $fatal(1, "randomize failed");
        r = i;
        instr_list.push_back({tx.imm12, 5'd0, 3'b000, r, 7'b0010011}); // ADDI xr, x0, imm12
      end
      
      total = instr_list.size() + n;

      // random instructions
      while (instr_list.size() < total) begin
        if (!kp.randomize()) $fatal(1, "pick randomize failed");
        pick = kp.pick;
        if (pick < 3)  k = instruction_transaction::K_MISC;
        else if (pick < 25) k = instruction_transaction::K_R;
        else if (pick < 40) k = instruction_transaction::K_I;
        else if (pick < 50) k = instruction_transaction::K_SHIFT;
        else if (pick < 55) k = instruction_transaction::K_LUI;
        else if (pick < 60) k = instruction_transaction::K_AUIPC;
        else if (pick < 75) k = instruction_transaction::K_LOAD;
        else if (pick < 85) k = instruction_transaction::K_STORE;
        else if (pick < 92) k = instruction_transaction::K_BRANCH;
        else if (pick < 96) k = instruction_transaction::K_JAL;
        else k = instruction_transaction::K_JALR;

        if (k == instruction_transaction::K_JALR) begin
          pos = instr_list.size();
          if ((total - pos < 2) || is_tgt[pos + 1]) k = instruction_transaction::K_JAL;
        end

        if (k == instruction_transaction::K_LOAD) begin
          case (kp.idx % 5)
            0: f3 = 3'b000;
            1: f3 = 3'b001;
            2: f3 = 3'b010;
            3: f3 = 3'b100;
            default: f3 = 3'b101;
          endcase
          if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");

          pos = instr_list.size();
          if ((kp.jmp % 2 == 1) && (total - pos >= 2) && !is_tgt[pos + 1]) begin
            rt = (kp.pick % 8) + 1;                                      // base register x1..x8
            bv = (kp.idx % 17) * 4;                                      // base value 0..64, multiple of 4
            instr_list.push_back({bv, 5'd0, 3'b000, rt, 7'b0010011});    // ADDI rt, x0, bv
            tx.rs1   = rt;                                               // load now uses rt as base
            tx.imm12 = tx.imm12 - bv;                                    // offset = target - base (often negative)
          end
        


        end else if (k == instruction_transaction::K_STORE) begin
          case (kp.idx % 3)
            0: f3 = 3'b000;
            1: f3 = 3'b001;
            default: f3 = 3'b010;
          endcase
          if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");

          pos = instr_list.size();
          if ((kp.jmp % 2 == 1) && (total - pos >= 2) && !is_tgt[pos + 1]) begin
            rt = (kp.pick % 8) + 1;                                      // base register x1..x8
            bv = (kp.idx % 17) * 4;                                      // base value 0..64, multiple of 4
            instr_list.push_back({bv, 5'd0, 3'b000, rt, 7'b0010011});    // ADDI rt, x0, bv
            tx.rs1   = rt;                                               // store now uses rt as base
            tx.imm12 = tx.imm12 - bv;                                    // offset = target - base (often negative)
          end

        end else if (k == instruction_transaction::K_BRANCH) begin
          case (br_cnt % 6)
            0: f3 = 3'b000;   // BEQ
            1: f3 = 3'b001;   // BNE
            2: f3 = 3'b100;   // BLT
            3: f3 = 3'b101;   // BGE
            4: f3 = 3'b110;   // BLTU
            default: f3 = 3'b111;   // BGEU
          endcase
          case (br_cnt % 12)        // operand mode: 0 = same register, 1 = rs1 -1 / rs2 x0, 2 = rs1 x0 / rs2 -1
            1, 2, 6, 9: bm = 1;
            4, 11:      bm = 2;
            default:    bm = 0;
          endcase
          pos   = instr_list.size();
          bfall = 1'b0;
          if (bm != 0 && ((total - pos < 2) || is_tgt[pos + 1])) begin
            bm    = 0;                // no room for the setup ADDI, or the branch is a jump target
            bfall = 1'b1;
          end
          if (!in_shadow[pos] && !bfall) br_cnt++;
          if (bm != 0) begin
            rt = (kp.pick % 8) + 1;
            instr_list.push_back({12'hFFF, 5'd0, 3'b000, rt, 7'b0010011});   // ADDI rt, x0, -1
            pos = instr_list.size();
          end
          maxk = total - pos;
          if (maxk > 4) maxk = 4;
          bk = (kp.jmp % maxk) + 1;
          is_tgt[pos + bk] = 1'b1;
          for (int s = pos + 1; s < pos + bk; s++) in_shadow[s] = 1'b1;
          if (bm == 1) begin
            if (!tx.randomize() with { kind == k; funct3 == f3; boff == bk * 4; rs1 == rt; rs2 == 0; }) $fatal(1, "randomize failed");
          end else if (bm == 2) begin
            if (!tx.randomize() with { kind == k; funct3 == f3; boff == bk * 4; rs1 == 0; rs2 == rt; }) $fatal(1, "randomize failed");
          end else begin
            if (!tx.randomize() with { kind == k; funct3 == f3; boff == bk * 4; rs2 == rs1; }) $fatal(1, "randomize failed");
          end
        end else if (k == instruction_transaction::K_JAL) begin
          pos  = instr_list.size();
          maxk = total - pos;
          if (maxk > 4) maxk = 4;
          bk = (kp.jmp % maxk) + 1;
          is_tgt[pos + bk] = 1'b1;
          for (int s = pos + 1; s < pos + bk; s++) in_shadow[s] = 1'b1;
          if (!tx.randomize() with { kind == k; boff == bk * 4; }) $fatal(1, "randomize failed");
        end else if (k == instruction_transaction::K_JALR) begin
          rt = (kp.idx % 8) + 1;
          k2 = instruction_transaction::K_AUIPC;
          if (!tx.randomize() with { kind == k2; rd == rt; imm20 == 0; }) $fatal(1, "randomize failed");
          instr_list.push_back(tx.to_word());
          pos  = instr_list.size();
          maxk = total - pos;
          if (maxk > 4) maxk = 4;
          bk = (kp.jmp % maxk) + 1;
          is_tgt[pos + bk] = 1'b1;
          for (int s = pos + 1; s < pos + bk; s++) in_shadow[s] = 1'b1;
          off = (bk + 1) * 4 + (pick % 2);
          k2 = instruction_transaction::K_JALR;
          if (!tx.randomize() with { kind == k2; rs1 == rt; imm12 == off; }) $fatal(1, "randomize failed");
        end else if (k == instruction_transaction::K_R) begin
          case (kp.idx % 10)
            0: begin f3 = 3'b000; alt_v = 1'b0; end   // ADD
            1: begin f3 = 3'b000; alt_v = 1'b1; end   // SUB
            2: begin f3 = 3'b001; alt_v = 1'b0; end   // SLL
            3: begin f3 = 3'b010; alt_v = 1'b0; end   // SLT
            4: begin f3 = 3'b011; alt_v = 1'b0; end   // SLTU
            5: begin f3 = 3'b100; alt_v = 1'b0; end   // XOR
            6: begin f3 = 3'b101; alt_v = 1'b0; end   // SRL
            7: begin f3 = 3'b101; alt_v = 1'b1; end   // SRA
            8: begin f3 = 3'b110; alt_v = 1'b0; end   // OR
            default: begin f3 = 3'b111; alt_v = 1'b0; end   // AND
          endcase
          if (!tx.randomize() with { kind == k; funct3 == f3; alt == alt_v; }) $fatal(1, "randomize failed");
        end else if (k == instruction_transaction::K_MISC) begin
          case (kp.idx % 3)
            0: f3 = 3'b000;   // FENCE
            1: f3 = 3'b001;   // ECALL
            default: f3 = 3'b010;   // EBREAK
          endcase
          if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");
        end else if (k == instruction_transaction::K_I) begin
          case (i_cnt % 6)
            0: f3 = 3'b000;   // ADDI
            1: f3 = 3'b010;   // SLTI
            2: f3 = 3'b011;   // SLTIU
            3: f3 = 3'b100;   // XORI
            4: f3 = 3'b110;   // ORI
            default: f3 = 3'b111;   // ANDI
          endcase
          if (!in_shadow[instr_list.size()]) i_cnt++;
          if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");
        end else if (k == instruction_transaction::K_SHIFT) begin
          case (sh_cnt % 3)
            0: begin f3 = 3'b001; alt_v = 1'b0; end   // SLLI
            1: begin f3 = 3'b101; alt_v = 1'b0; end   // SRLI
            default: begin f3 = 3'b101; alt_v = 1'b1; end   // SRAI
          endcase
          if (!in_shadow[instr_list.size()]) sh_cnt++;
          if (!tx.randomize() with { kind == k; funct3 == f3; alt == alt_v; }) $fatal(1, "randomize failed");  
        end else begin
          if (!tx.randomize() with { kind == k; }) $fatal(1, "randomize failed");
        end

        instr_list.push_back(tx.to_word());
      end

      // fixed counted loop at the end: trains the branch predictor and BTB
      instr_list.push_back(32'h00500093);   // ADDI x1, x0, 5
      instr_list.push_back(32'hFFF08093);   // loop: ADDI x1, x1, -1
      instr_list.push_back(32'hFE009EE3);   // BNE  x1, x0, loop (taken 4 times, then falls through)

      // print the program
      $display("Random program, seed%0d, %0d instruction:", seed, instr_list.size());
      foreach (instr_list[i]) $display(" [%0d] %h", i, instr_list[i]);
    endfunction

    // fixed edge-case programs, chosen by id (+TEST=id)
    function void load_directed(int id);
      instr_list.delete();
      case (id)
        1: begin   // back-to-back load-use stalls
          instr_list.push_back(32'h06400093); // ADDI x1,x0,100
          instr_list.push_back(32'h00700113); // ADDI x2,x0,7
          instr_list.push_back(32'h00102023); // SW   x1,0(x0)     mem[0] = 100
          instr_list.push_back(32'h00202223); // SW   x2,4(x0)     mem[4] = 7
          instr_list.push_back(32'h06202223); // SW   x2,100(x0)   mem[100] = 7
          instr_list.push_back(32'h00002183); // LW   x3,0(x0)     x3 = 100
          instr_list.push_back(32'h00318233); // ADD  x4,x3,x3     stall, x4 = 200
          instr_list.push_back(32'h00402283); // LW   x5,4(x0)     x5 = 7
          instr_list.push_back(32'h00428333); // ADD  x6,x5,x4     stall, x6 = 207
          instr_list.push_back(32'h00002383); // LW   x7,0(x0)     x7 = 100
          instr_list.push_back(32'h00402403); // LW   x8,4(x0)     x8 = 7
          instr_list.push_back(32'h008380B3); // ADD  x1,x7,x8     stall, x1 = 107
          instr_list.push_back(32'h00002183); // LW   x3,0(x0)     x3 = 100
          instr_list.push_back(32'h0001A203); // LW   x4,0(x3)     stall (base from load), x4 = 7
          instr_list.push_back(32'h00102423); // SW   x1,8(x0)     mem[8] = 107
          instr_list.push_back(32'h00802103); // LW   x2,8(x0)     x2 = 107
          instr_list.push_back(32'h00202623); // SW   x2,12(x0)    stall (store data from load), mem[12] = 107
        end
        2: begin   // store then load from the same address, partial stores, sign/zero extension
          instr_list.push_back(32'h12300093); // ADDI x1,x0,0x123
          instr_list.push_back(32'h00102823); // SW   x1,16(x0)     mem[16] = 0x123
          instr_list.push_back(32'h01002103); // LW   x2,16(x0)     x2 = 0x123 (right after the store)
          instr_list.push_back(32'hFFF00193); // ADDI x3,x0,-1
          instr_list.push_back(32'h00302A23); // SW   x3,20(x0)     mem[20] = 0xFFFFFFFF
          instr_list.push_back(32'h01402203); // LW   x4,20(x0)     x4 = 0xFFFFFFFF
          instr_list.push_back(32'h00100A23); // SB   x1,20(x0)     byte 0 = 0x23
          instr_list.push_back(32'h01402283); // LW   x5,20(x0)     x5 = 0xFFFFFF23
          instr_list.push_back(32'h00101B23); // SH   x1,22(x0)     upper half = 0x0123
          instr_list.push_back(32'h01402303); // LW   x6,20(x0)     x6 = 0x0123FF23
          instr_list.push_back(32'h01400383); // LB   x7,20(x0)     x7 = 0x23
          instr_list.push_back(32'h01504403); // LBU  x8,21(x0)     x8 = 0xFF
          instr_list.push_back(32'h01401103); // LH   x2,20(x0)     x2 = 0xFFFFFF23 (sign-extended)
          instr_list.push_back(32'h01405183); // LHU  x3,20(x0)     x3 = 0xFF23
          instr_list.push_back(32'h00202C23); // SW   x2,24(x0)     mem[24] = 0xFFFFFF23
          instr_list.push_back(32'h01802203); // LW   x4,24(x0)     x4 = 0xFFFFFF23
          instr_list.push_back(32'h00500293); // ADDI x5,x0,5
          instr_list.push_back(32'h00502E23); // SW   x5,28(x0)     mem[28] = 5
          instr_list.push_back(32'h00600293); // ADDI x5,x0,6
          instr_list.push_back(32'h00502E23); // SW   x5,28(x0)     mem[28] = 6 (overwrite)
          instr_list.push_back(32'h01C02303); // LW   x6,28(x0)     x6 = 6
        end
        3: begin   // shifts by 0 and 31, register shift amounts use only the low 5 bits
          instr_list.push_back(32'hFFF00093); // ADDI x1,x0,-1
          instr_list.push_back(32'h80000137); // LUI  x2,0x80000    x2 = 0x80000000
          instr_list.push_back(32'h00009193); // SLLI x3,x1,0       x3 = 0xFFFFFFFF
          instr_list.push_back(32'h01F09213); // SLLI x4,x1,31      x4 = 0x80000000
          instr_list.push_back(32'h0000D293); // SRLI x5,x1,0       x5 = 0xFFFFFFFF
          instr_list.push_back(32'h01F0D313); // SRLI x6,x1,31      x6 = 1
          instr_list.push_back(32'h40015393); // SRAI x7,x2,0       x7 = 0x80000000
          instr_list.push_back(32'h41F15413); // SRAI x8,x2,31      x8 = 0xFFFFFFFF
          instr_list.push_back(32'h02000193); // ADDI x3,x0,32      shift amount 32 -> 0
          instr_list.push_back(32'h00309233); // SLL  x4,x1,x3      x4 = 0xFFFFFFFF
          instr_list.push_back(32'h003152B3); // SRL  x5,x2,x3      x5 = 0x80000000
          instr_list.push_back(32'h03F00193); // ADDI x3,x0,63      shift amount 63 -> 31
          instr_list.push_back(32'h00309333); // SLL  x6,x1,x3      x6 = 0x80000000
          instr_list.push_back(32'h0030D3B3); // SRL  x7,x1,x3      x7 = 1
          instr_list.push_back(32'h40315433); // SRA  x8,x2,x3      x8 = 0xFFFFFFFF
          instr_list.push_back(32'h4030D0B3); // SRA  x1,x1,x3      x1 = 0xFFFFFFFF
          instr_list.push_back(32'h01F15113); // SRLI x2,x2,31      x2 = 1
        end
        4: begin   // signed boundaries and signed vs unsigned compares
          instr_list.push_back(32'h800000B7); // LUI   x1,0x80000    x1 = 0x80000000
          instr_list.push_back(32'hFFF08113); // ADDI  x2,x1,-1      x2 = 0x7FFFFFFF
          instr_list.push_back(32'h00110193); // ADDI  x3,x2,1       x3 = 0x80000000
          instr_list.push_back(32'h00210233); // ADD   x4,x2,x2      x4 = 0xFFFFFFFE
          instr_list.push_back(32'h402082B3); // SUB   x5,x1,x2      x5 = 1
          instr_list.push_back(32'h40110333); // SUB   x6,x2,x1      x6 = 0xFFFFFFFF
          instr_list.push_back(32'h0020A3B3); // SLT   x7,x1,x2      x7 = 1
          instr_list.push_back(32'h0020B433); // SLTU  x8,x1,x2      x8 = 0
          instr_list.push_back(32'h001121B3); // SLT   x3,x2,x1      x3 = 0
          instr_list.push_back(32'h00113233); // SLTU  x4,x2,x1      x4 = 1
          instr_list.push_back(32'hFFF0A293); // SLTI  x5,x1,-1      x5 = 1
          instr_list.push_back(32'hFFF0B313); // SLTIU x6,x1,-1      x6 = 1
          instr_list.push_back(32'hFFF00413); // ADDI  x8,x0,-1      x8 = 0xFFFFFFFF
          instr_list.push_back(32'h00043113); // SLTIU x2,x8,0       x2 = 0
          instr_list.push_back(32'h00042193); // SLTI  x3,x8,0       x3 = 1
          instr_list.push_back(32'hFFF44213); // XORI  x4,x8,-1      x4 = 0
          instr_list.push_back(32'h7FF47293); // ANDI  x5,x8,0x7FF   x5 = 0x7FF
          instr_list.push_back(32'hFFF06313); // ORI   x6,x0,-1      x6 = 0xFFFFFFFF
          instr_list.push_back(32'h000423B3); // SLT   x7,x8,x0      x7 = 1
          instr_list.push_back(32'h008030B3); // SLTU  x1,x0,x8      x1 = 1
        end
        5: begin   // branch as the very last instruction (taken, target = end of program)
          instr_list.push_back(32'h00100093); // ADDI x1,x0,1
          instr_list.push_back(32'h00200113); // ADDI x2,x0,2
          instr_list.push_back(32'h002081B3); // ADD  x3,x1,x2       x3 = 3
          instr_list.push_back(32'h00000263); // BEQ  x0,x0,+4       taken, last instruction
        end
        6: begin   // repeated branches: nested loop and a loop whose BEQ finally takes
          instr_list.push_back(32'h00300093); // ADDI x1,x0,3        outer count
          instr_list.push_back(32'h00400113); // outer: ADDI x2,x0,4 inner count
          instr_list.push_back(32'hFFF10113); // inner: ADDI x2,x2,-1
          instr_list.push_back(32'hFE011EE3); // BNE  x2,x0,inner    T T T N, x3
          instr_list.push_back(32'hFFF08093); // ADDI x1,x1,-1
          instr_list.push_back(32'hFE0098E3); // BNE  x1,x0,outer    T T N
          instr_list.push_back(32'h06300193); // ADDI x3,x0,99
          instr_list.push_back(32'h00400213); // ADDI x4,x0,4
          instr_list.push_back(32'hFFF20213); // loop2: ADDI x4,x4,-1
          instr_list.push_back(32'h00020463); // BEQ  x4,x0,done     N N N T
          instr_list.push_back(32'hFF9FF06F); // JAL  x0,loop2
          instr_list.push_back(32'h03700293); // done: ADDI x5,x0,55 x5 = 55
        end
        7: begin   // BTB aliasing: branches 64 instructions apart share one BTB entry
          instr_list.push_back(32'h00300093);             // [0]  ADDI x1,x0,3      outer count
          repeat (5) instr_list.push_back(32'h00000013);  // [1..5] NOPs
          instr_list.push_back(32'h00300193);             // [6]  outer: ADDI x3,x0,3
          instr_list.push_back(32'hFFF18193);             // [7]  loopA: ADDI x3,x3,-1
          instr_list.push_back(32'hFE019EE3);             // [8]  A: BNE x3,x0,loopA   (BTB index 8, tag 0)
          instr_list.push_back(32'h00128293);             // [9]  ADDI x5,x5,1
          repeat (60) instr_list.push_back(32'h00000013); // [10..69] NOPs
          instr_list.push_back(32'h00300213);             // [70] ADDI x4,x0,3
          instr_list.push_back(32'hFFF20213);             // [71] loopB: ADDI x4,x4,-1
          instr_list.push_back(32'hFE021EE3);             // [72] B: BNE x4,x0,loopB   (BTB index 8, tag 1)
          instr_list.push_back(32'h00130313);             // [73] ADDI x6,x6,1
          instr_list.push_back(32'hFFF08093);             // [74] ADDI x1,x1,-1
          instr_list.push_back(32'hEE0096E3);             // [75] BNE x1,x0,outer
        end
        default: $fatal(1, "unknown directed test id %0d", id);
      endcase
      $display("Directed test %0d, %0d instructions:", id, instr_list.size());
      foreach (instr_list[i]) $display(" [%0d] %h", i, instr_list[i]);
    endfunction
    

    task run();
        instruction_transaction tx;
        foreach (instr_list[i]) begin
            tx = new();
            tx.instruction = instr_list[i];
            $display("Sequencer generated: instr=%h", tx.instruction);
        end
    endtask
    

endclass