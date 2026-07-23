// control_hazard_unit.sv
// Detects if instruction is a branch or jump and signals to flush
// the wrongly fetched instructions sitting in IF_ID and ID_EX

module control_hazard_unit (
    input logic idex_branch,
    input logic ex_zero,
    input logic idex_jump,

    output logic flush
);

    always_comb begin
        flush = 1'b0;

        if (idex_jump)
            flush = 1'b1;

        else if (idex_branch && ex_zero)
            flush = 1'b1;
        end
endmodule 
