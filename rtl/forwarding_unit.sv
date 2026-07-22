// forwarding_unit.sv
// selects correct ALU operand values between
// ID_EX data, or forwarded values from EX/MEM or MEM/WB data

module forwarding_unit (
    input logic [31:0] idex_rs1_data,
    input logic [31:0] idex_rs2_data,

    input logic [31:0] exmem_alu_result,
    input logic [31:0] wb_write_back_data,

    input logic [1:0] forward_a,
    input logic [1:0] forward_b,

    output logic [31:0] alu_operand_a,
    output logic [31:0] alu_operand_b

);

    always_comb begin
        case (forward_a)
            2'b00: alu_operand_a = idex_rs1_data;
            2'b01: alu_operand_a = exmem_alu_result;
            2'b10: alu_operand_a = wb_write_back_data;
            default: alu_operand_a = idex_rs1_data;
        endcase
        
        case (forward_b) 
            2'b00: alu_operand_b = idex_rs2_data;
            2'b01: alu_operand_b = exmem_alu_result;
            2'b10: alu_operand_b = wb_write_back_data;
            default: alu_operand_b = idex_rs2_data;
        endcase
    end
endmodule 