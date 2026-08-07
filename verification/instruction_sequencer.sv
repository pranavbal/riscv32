// instruction_sequencer.sv
// generates a stream of instruction_transaction objections from a fixed instruction list (for now)

class instruction_sequencer;

    logic [31:0] instr_list [0:9];

    function new();
        instr_list[0] = 32'h00500093; // ADD x1, x0, 5
        instr_list[1] = 32'h00A00113; // ADD x2, x0, 10
        instr_list[2] = 32'h002081B3; // ADD x3, x1, x2
        instr_list[3] = 32'h40118233; // SUB  x4, x3, x1
        instr_list[4] = 32'h00402023; // SW   x4, 0(x0)
        instr_list[5] = 32'h00002283; // LW   x5, 0(x0)
        instr_list[6] = 32'h00128333; // ADD  x6, x5, x1
        instr_list[7] = 32'h00108463; // BEQ  x1, x1, +8
        instr_list[8] = 32'h06300393; // ADDI x7, x0, 99 (skipped)
        instr_list[9] = 32'h04D00413; // ADDI x8, x0, 77 (branch target)
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