// instruction_sequencer.sv
// generates a stream of instruction_transaction objections from a fixed instruction list (for now)

class instruction_sequencer;

    logic [31:0] instr_list [0:9];

    function new();
        // ORIGINAL PROGRAM 
        instr_list[0] = 32'h00500093; // ADDI x1,x0,5    x1 = 5
        instr_list[1] = 32'h00A00113; // ADDI x2,x0,10   x2 = 10
        instr_list[2] = 32'h002081B3; // ADD  x3,x1,x2   x3 = 15
        instr_list[3] = 32'h40118233; // SUB  x4,x3,x1   x4 = 10
        instr_list[4] = 32'h00402023; // SW   x4,0(x0)   mem[0] = 10
        instr_list[5] = 32'h00002283; // LW   x5,0(x0)   x5 = 10
        instr_list[6] = 32'h00128333; // ADD  x6,x5,x1   x6 = 15
        instr_list[7] = 32'h00108463; // BEQ  x1,x1,+8   taken
        instr_list[8] = 32'h06300393; // ADDI x7,x0,99   skipped
        instr_list[9] = 32'h04D00413; // ADDI x8,x0,77   x8 = 77

        // LUI
        // instr_list[0] = 32'h000012B7; // LUI  x5,0x1     x5  = 4096
        // instr_list[1] = 32'h00128313; // ADDI x6,x5,1    x6  = 4097 (EX/MEM forward from LUI)
        // instr_list[2] = 32'h00000013; // NOP             no write
        // instr_list[3] = 32'h00728013; // ADDI x0,x5,7    no write (x0)
        // instr_list[4] = 32'h005003B3; // ADD  x7,x0,x5   x7  = 4096 (x0 must read 0)
        // instr_list[5] = 32'h00002437; // LUI  x8,0x2     x8  = 8192
        // instr_list[6] = 32'h00300493; // ADDI x9,x0,3    x9  = 3
        // instr_list[7] = 32'h00940533; // ADD  x10,x8,x9  x10 = 8195 (MEM/WB forward from LUI)
        // instr_list[8] = 32'h00030593; // ADDI x11,x6,0   x11 = 4097
        // instr_list[9] = 32'h00000013; // NOP             no write
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