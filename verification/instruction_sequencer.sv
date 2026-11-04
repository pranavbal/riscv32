// instruction_sequencer.sv
// generates a stream of instruction_transaction objections from a fixed instruction list (for now)


class kind_picker;
    rand int unsigned pick;
    rand int unsigned idx;
    constraint c_pick { pick < 100; }
    constraint c_idx  { idx < 60; }
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
      instr_list.delete();
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
    
    // random instructions
    repeat (n) begin
      if (!kp.randomize()) $fatal(1, "pick randomize failed");
      pick = kp.pick;
      if      (pick < 30) k = instruction_transaction::K_R;
      else if (pick < 50) k = instruction_transaction::K_I;
      else if (pick < 60) k = instruction_transaction::K_SHIFT;
      else if (pick < 65) k = instruction_transaction::K_LUI;
      else if (pick < 70) k = instruction_transaction::K_AUIPC;
      else if (pick < 90) k = instruction_transaction::K_LOAD;
      else                k = instruction_transaction::K_STORE;

      if (k == instruction_transaction::K_LOAD) begin
        case (kp.idx % 5)
          0: f3 = 3'b000;
          1: f3 = 3'b001;
          2: f3 = 3'b010;
          3: f3 = 3'b100;
          default: f3 = 3'b101;
        endcase
        if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");
      end else if (k == instruction_transaction::K_STORE) begin
        case (kp.idx % 3)
          0: f3 = 3'b000;
          1: f3 = 3'b001;
          default: f3 = 3'b010;
        endcase
        if (!tx.randomize() with { kind == k; funct3 == f3; }) $fatal(1, "randomize failed");
      end else begin
        if (!tx.randomize() with { kind == k; }) $fatal(1, "randomize failed");
      end

      instr_list.push_back(tx.to_word());
    end

    // print the program
    $display("Random program, seed%0d, %0d instruction:", seed, instr_list.size());
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