// hazard_detection_unit.sv
// Detects when forwarding is needed by comparing...
// ...ID_EX's source registers with EX_MEM and MEM_WB's destination registers


module hazard_detection_unit (
    input logic [4:0] idex_rs1_addr,
    input logic [4:0] idex_rs2_addr,

    input logic [4:0] exmem_rd_addr,
    input logic exmem_reg_write,

    input logic [4:0] memwb_rd_addr,
    input logic memwb_reg_write,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if(exmem_reg_write && (exmem_rd_addr != 5'd0) && (exmem_rd_addr == idex_rs1_addr))
            forward_a = 2'b01;
        else if (memwb_reg_write && (memwb_rd_addr != 5'd0) && (memwb_rd_addr == idex_rs1_addr))
            forward_a = 2'b10;

        if (exmem_reg_write && (exmem_rd_addr != 5'd0) && (exmem_rd_addr == idex_rs2_addr))
            forward_b = 2'b01;
        else if (memwb_reg_write && (memwb_rd_addr != 5'd0) && (memwb_rd_addr == idex_rs2_addr))
            forward_b = 2'b10;
        end

endmodule 
