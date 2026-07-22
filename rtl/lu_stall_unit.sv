// lu_stall_unit.sv
// Load-use stall detection unit
// Checkc ID_EX to see if its a load whose rd matches a rs1 or rs2 of 
// an instruction currently in ID

module lu_stall_unit (
    input logic [1:0] idex_mem_to_reg,
    input logic [4:0] idex_rd_addr,

    input logic [4:0] id_rs1_addr,
    input logic [4:0] id_rs2_addr,

    output logic stall

);

always_comb begin
    stall = 1'b0;

    if ((idex_mem_to_reg == 2'b01) && 
        (idex_rd_addr != 5'd0) &&
        ((idex_rd_addr == id_rs1_addr) || (idex_rd_addr == id_rs2_addr)))
        stall = 1'b1;
end

endmodule