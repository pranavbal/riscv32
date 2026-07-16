// datapath.sv
// Connects all the CPU components together
// Single-cycle datapath

module datapath(
    input logic clk,
    input logic rst
);

    // Internal wires connecting components
    logic [31:0] pc_current, pc_next, pc_plus_4;
    logic [31:0] instruction;
    logic [6:0] opcode, funct7;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] imm;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic zero;
    logic [31:0] mem_read_data;
    logic [31:0] write_back_data;
    logic [31:0] branch_target;

    // Control signals from control unit
    logic reg_write, we, alu_src, branch, jump;
    logic [1:0] mem_to_reg;
    logic [3:0] alu_control;

    // Program Counter
    program_counter pc_reg (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_current)
    );

    // Instruction Memory
    instruction_memory imem (
        .addr(pc_current),
        .instruction(instruction)
    );

    // Instruction Decoder
    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    // Immediate generator
    immediate_generator immgen (
        .instruction(instruction),
        .imm(imm)
    );

    // Control unit
    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .we(we),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    // Register File
    register_file regfile (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rd),
        .rd_data(write_back_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ALU input MUX - select rs2 or immediate
    assign alu_operand_b = alu_src ? imm : rs2_data;

    // ALU
    alu alu_unit (
        .a(rs1_data),
        .b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero)
    );

    // Data Memory
    data_memory dmem (
        .clk(clk),
        .we(we),
        .addr(alu_result),
        .wd(rs2_data),
        .rd(mem_read_data)
    );

    // Write Back MUX - select ALU result or memory data or PC + 4, or immediate
    always_comb begin
        case (mem_to_reg)
            2'b00: write_back_data = alu_result;
            2'b01: write_back_data = mem_read_data;
            2'b10: write_back_data = pc_plus_4;
            2'b11: write_back_data = imm;
            default: write_back_data = alu_result;
        endcase
    end

    // PC+4 adder
    assign pc_plus_4 = pc_current + 32'd4;

    // Branch/Jump target adder
    assign branch_target = pc_current + imm;

    // PC next MUX - select PC+4, branch target or jump target
    assign pc_next = (jump) ? branch_target :
                        (branch && zero) ? branch_target :
                            pc_plus_4;
                            
endmodule