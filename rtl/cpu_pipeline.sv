// cpu_pipeline.sv
// Top-level pipeline wrapper - Pass 1 (no hazard handling yet)

module cpu_pipeline (
    input logic clk,
    input logic rst
);

    // PC-next mux
    logic [31:0] pc_next;
    //----------------------------------------------------------------
    // if_stage
    logic [31:0] if_instruction;
    logic [31:0] if_pc_current;

    if_stage IF (
        .clk(clk),
        .rst(rst),
        .pc_next_in(pc_next),
        .instruction_out(if_instruction),
        .pc_current_out(if_pc_current)
    );
    //----------------------------------
    // if_id register
    logic[31:0] ifid_instruction, ifid_pc_current;

    if_id_reg IF_ID (
        .clk(clk),
        .rst(rst),
        .instruction_in(if_instruction),
        .pc_current_in(if_pc_current),
        .instruction_out(ifid_instruction),
        .pc_current_out(ifid_pc_current)
    
    );
    //----------------------------------------------------------------
    // id_stage

    //all the output wires
    logic [31:0] id_rs1_data;
    logic [31:0] id_rs2_data;
    logic [31:0] id_imm;
    logic [4:0] id_rs1_addr;
    logic [4:0] id_rs2_addr;
    logic [4:0] id_rd_addr;

    // control unit output wires
    logic id_reg_write;
    logic id_we;
    logic id_alu_src;
    logic [3:0] id_alu_control;
    logic [1:0] id_mem_to_reg;
    logic id_branch;
    logic id_jump;

    // write-back wires
    logic [31:0] wb_write_back_data;
    logic [4:0] wb_write_back_addr;
    logic       wb_reg_write_final;

    id_stage ID (
        .clk(clk),
        .rst(rst),
        .instruction_in(ifid_instruction),
        .wb_data(wb_write_back_data),
        .wb_rd_addr(wb_write_back_addr),
        .wb_reg_write(wb_reg_write_final),
        .rs1_data_out(id_rs1_data),
        .rs2_data_out(id_rs2_data),
        .rs1_addr_out(id_rs1_addr),
        .rs2_addr_out(id_rs2_addr),
        .rd_addr_out(id_rd_addr),
        .imm_out(id_imm),
        .reg_write_out(id_reg_write),
        .we_out(id_we),
        .alu_src_out(id_alu_src),
        .alu_control_out(id_alu_control),
        .mem_to_reg_out(id_mem_to_reg),
        .branch_out(id_branch),
        .jump_out(id_jump)
    );

    //----------------------------------
    // id_ex register

    // the output wires
    logic [31:0] idex_pc_current;
    logic [31:0] idex_rs1_data;
    logic [31:0] idex_rs2_data;
    logic [31:0] idex_imm;
    logic [4:0] idex_rs1_addr;
    logic [4:0] idex_rs2_addr;
    logic [4:0] idex_rd_addr;
    logic idex_reg_write;
    logic idex_we;
    logic idex_alu_src;
    logic idex_branch;
    logic idex_jump;
    logic [3:0] idex_alu_control;
    logic [1:0] idex_mem_to_reg;

    id_ex_reg ID_EX (
        .clk(clk),
        .rst(rst),
        .pc_current_in(ifid_pc_current),
        .rs1_data_in(id_rs1_data),
        .rs2_data_in(id_rs2_data),
        .imm_in(id_imm),
        .rs1_addr_in(id_rs1_addr),
        .rs2_addr_in(id_rs2_addr),
        .rd_addr_in(id_rd_addr),
        .reg_write_in(id_reg_write),
        .we_in(id_we),
        .alu_src_in(id_alu_src),
        .alu_control_in(id_alu_control),
        .mem_to_reg_in(id_mem_to_reg),
        .branch_in(id_branch),
        .jump_in(id_jump),

        .pc_current_out(idex_pc_current),
        .rs1_data_out(idex_rs1_data),
        .rs2_data_out(idex_rs2_data),
        .imm_out(idex_imm),
        .rs1_addr_out(idex_rs1_addr),
        .rs2_addr_out(idex_rs2_addr),
        .rd_addr_out(idex_rd_addr),
        .reg_write_out(idex_reg_write),
        .we_out(idex_we),
        .alu_src_out(idex_alu_src),
        .alu_control_out(idex_alu_control),
        .mem_to_reg_out(idex_mem_to_reg),
        .branch_out(idex_branch),
        .jump_out(idex_jump)

    );

    //----------------------------------------------------------------
    // ex_stage

    logic [31:0] ex_alu_result;
    logic [31:0] ex_pc_plus_4;
    logic [31:0] ex_branch_target;
    logic ex_zero;

    ex_stage EX (
        .pc_current_in(idex_pc_current),
        .rs1_data_in(idex_rs1_data),
        .rs2_data_in(idex_rs2_data),
        .imm_in(idex_imm),
        .alu_src_in(idex_alu_src),
        .alu_control_in(idex_alu_control),

        .alu_result_out(ex_alu_result),
        .zero_out(ex_zero),
        .pc_plus_4_out(ex_pc_plus_4),
        .branch_target_out(ex_branch_target)

    );

    // PC-next MUX- uses EX's zero / branch_target result
    
    // branch / jump is carried through ID / EX (bypassing ex_stage)

    always_comb begin
        if (idex_jump)
            pc_next = ex_branch_target;
        else if (idex_branch && ex_zero)
            pc_next = ex_branch_target;
        else
            pc_next = if_pc_current + 32'd4; // default next instruction

    end

    //----------------------------------
    // ex_mem register

    logic [31:0] exmem_alu_result;
    logic [31:0] exmem_rs2_data;
    logic [31:0] exmem_pc_plus_4;
    logic [31:0] exmem_imm;
    logic[4:0] exmem_rd_addr;
    logic [1:0] exmem_mem_to_reg;
    logic exmem_zero;
    logic exmem_reg_write;
    logic exmem_we;

    ex_mem_reg EX_MEM (
        .clk(clk),
        .rst(rst),
        .alu_result_in(ex_alu_result),
        .rs2_data_in(idex_rs2_data),
        .pc_plus_4_in(ex_pc_plus_4),
        .imm_in(idex_imm),
        .rd_addr_in(idex_rd_addr),
        .zero_in(ex_zero),
        .reg_write_in(idex_reg_write),
        .we_in(idex_we),
        .mem_to_reg_in(idex_mem_to_reg),

        .alu_result_out(exmem_alu_result),
        .rs2_data_out(exmem_rs2_data),
        .pc_plus_4_out(exmem_pc_plus_4),
        .imm_out(exmem_imm),
        .rd_addr_out(exmem_rd_addr),
        .zero_out(exmem_zero),
        .reg_write_out(exmem_reg_write),
        .we_out(exmem_we),
        .mem_to_reg_out(exmem_mem_to_reg)
        
    );

    //----------------------------------------------------------------
    // mem_stage

    logic [31:0] mem_read_data;

    mem_stage MEM (
        .clk(clk),
        .we_in(exmem_we),
        .alu_result_in(exmem_alu_result),
        .rs2_data_in(exmem_rs2_data),
        .mem_read_data_out(mem_read_data)
    );

    //----------------------------------
    // mem_wb register register

    logic [31:0] memwb_alu_result;
    logic [31:0] memwb_mem_read_data;
    logic [4:0] memwb_rd_addr;
    logic [31:0] memwb_pc_plus_4;
    logic [31:0] memwb_imm;
    logic memwb_reg_write;
    logic [1:0] memwb_mem_to_reg;

    mem_wb_reg MEM_WB(
        .clk(clk),
        .rst(rst),
        .alu_result_in(exmem_alu_result),
        .mem_read_data_in(mem_read_data),
        .rd_addr_in(exmem_rd_addr),
        .pc_plus_4_in(exmem_pc_plus_4),
        .imm_in(exmem_imm),
        .reg_write_in(exmem_reg_write),
        .mem_to_reg_in(exmem_mem_to_reg),

        .alu_result_out(memwb_alu_result),
        .mem_read_data_out(memwb_mem_read_data),
        .rd_addr_out(memwb_rd_addr),
        .pc_plus_4_out(memwb_pc_plus_4),
        .imm_out(memwb_imm),
        .reg_write_out(memwb_reg_write),
        .mem_to_reg_out(memwb_mem_to_reg)

    );

    //----------------------------------------------------------------
    // wb_stage
    wb_stage WB(
        .alu_result_in(memwb_alu_result),
        .data_read_memory_in(memwb_mem_read_data),
        .pc_plus_4_in(memwb_pc_plus_4),
        .imm_in(memwb_imm),
        .mem_to_reg_in(memwb_mem_to_reg),
        .write_back_data_out(wb_write_back_data)
    
    );

    // Write-back loop into ID stage
    assign wb_write_back_addr = memwb_rd_addr;
    assign wb_reg_write_final = memwb_reg_write;

endmodule





    

