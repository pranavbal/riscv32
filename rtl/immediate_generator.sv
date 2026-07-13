// immediate_generator.sv
// Reassembles and sign extends immediates for all 6 instruction formats

module immediate_generator (
    input logic [31:0] instruction,
    output logic [31:0] imm
);

    logic [6:0] opcode;
    assign opcode = instruction[6:0];

    always_comb begin
        case (opcode)
            // I-type - ADDI, loads, JALR
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type - stores
            7'b0100011: begin
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // B-type - branches
            7'b1100011: begin
                imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end

            // U-type - LUI, AUIPC
            7'b0110111, 7'b0010111: begin
                imm = {instruction[31:12], 12'b0};
            end

            // J-type - JAL
            7'b1101111: begin
                imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            default: imm = 32'b0;
        endcase
    end
endmodule

