// branch_condition_unit.sv
// Determines if a branch is taken based on funct3 and the ALU's result 
// we use the zero flag for BEQ/BNE and SLT/SLTU for the others.

module branch_condition_unit (
    input logic [2:0] funct3,
    input logic zero,
    input logic [31:0] alu_result,

    output logic branch_taken
);

    always_comb begin
        case (funct3)
            3'b000: branch_taken = zero;             // BEQ
            3'b001: branch_taken = !zero;            // BNE
            3'b100: branch_taken = alu_result[0];    // BLT
            3'b101: branch_taken = !alu_result[0];   // BGE
            3'b110: branch_taken = alu_result[0];    // BLTU
            3'b111: branch_taken = !alu_result[0];   // BGEU
            default: branch_taken = 1'b0;
        endcase
    end
endmodule
