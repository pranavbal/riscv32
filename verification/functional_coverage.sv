// functional_coverage.sv
// tracks which RV32I instructions/behaviors have been exercised

class functional_coverage;

    logic [6:0] current_opcode;

    covergroup instruction_coverage;
        coverpoint current_opcode {
            bins r_type = {7'b0110011};
            bins i_type = {7'b0010011};
            bins load = {7'b0000011};
            bins store = {7'b0100011};
            bins branch = {7'b1100011};
            bins lui = {7'b0110111};
            bins auipc = {7'b0010111};
            bins jal = {7'b1101111};
            bins jalr = {7'b1100111};
            bins misc = {7'b0001111, 7'b1110011};

        }
    endgroup

    function new();
        instruction_coverage = new();
    endfunction

    function void sample(logic [31:0] instruction);
        current_opcode = instruction[6:0];
        instruction_coverage.sample();
    endfunction

endclass