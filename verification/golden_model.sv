// golden_model.sv

class golden_model;
    logic [31:0] gm_registers [31:0];   // 32 registers each 32 bits wide
    logic [31:0] gm_memory [0:1023];    // 1024 memory spaces each 32 bits wide
    logic [31:0] gm_pc;                 // golden model's program counte

    function new();
     foreach (gm_registers[i]) begin
        gm_registers[i] = 32'b0;
     end
     gm_pc = 32'b0;
    endfunction

    // executes one instruction, which updates the gm_registers/gm_memory/gm_pc
    // exactly like a correct RV32I implentation would

    task execute(logic [31:0] instruction, output logic [4:0] out_rd, output logic [31:0] out_result, output logic out_reg_write);

        logic [6:0] opcode;
        logic [4:0] rd, rs1, rs2;
        logic [2:0] funct3;
        logic [6:0] funct7;
        logic [31:0] imm;
        logic [31:0] rs1_val, rs2_val, result;
        logic        take_branch;

        logic reg_write_happened;

        logic [31:0] addr;
        logic [31:0] word;
        logic [1:0] byte_off;
        logic [31:0] old_word;
        logic [31:0] new_word;
        logic [31:0] target;

        opcode = instruction[6:0];
        rd = instruction[11:7];
        funct3 = instruction[14:12];
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        funct7 = instruction[31:25];

        rs1_val = (rs1 == 5'b0) ? 32'b0 : gm_registers[rs1];
        rs2_val = (rs2 == 5'b0) ? 32'b0 : gm_registers[rs2];

        result = 32'b0;
        take_branch = 1'b0;
        reg_write_happened = 1'b0;

        case (opcode)

        // ----------------- R - TYPE ------------------
        7'b0110011: begin
            case ({funct7, funct3})
                {7'b0000000, 3'b000}: result = rs1_val + rs2_val;
                {7'b0100000, 3'b000}: result = rs1_val - rs2_val;
                {7'b0000000, 3'b001}: result = rs1_val << rs2_val[4:0];
                {7'b0000000, 3'b010}: result = ($signed(rs1_val) < $signed(rs2_val)) ? 32'd1 : 32'd0;
                {7'b0000000, 3'b011}: result = (rs1_val < rs2_val) ? 32'd1: 32'd0;
                {7'b0000000, 3'b100}: result = rs1_val ^ rs2_val;
                {7'b0000000, 3'b101}: result = rs1_val >> rs2_val[4:0];
                {7'b0100000, 3'b101}: result = $signed(rs1_val) >>> rs2_val[4:0];
                {7'b0000000, 3'b110}: result = rs1_val | rs2_val;
                {7'b0000000, 3'b111}: result = rs1_val & rs2_val;
                default: result = 32'b0;
            endcase
            if (rd != 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = gm_pc + 32'd4;
        end

        //--------------- I - TYPE -------------
        7'b0010011: begin
            imm = {{20{instruction[31]}}, instruction[31:20]};
            case (funct3)
                3'b000: result = rs1_val + imm;
                3'b010: result = ($signed(rs1_val) < $signed(imm)) ? 32'd1 : 32'd0;
                3'b011: result = (rs1_val < imm) ? 32'd1: 32'd0;
                3'b100: result = rs1_val ^ imm;
                3'b110: result = rs1_val | imm;
                3'b111: result = rs1_val & imm;
                3'b001: result = rs1_val << instruction [24:20];
                3'b101: begin
                    if (funct7 == 7'b0000000)
                        result = rs1_val >> instruction[24:20];
                    else
                        result = $signed(rs1_val) >>> instruction [24:20];
                    end
                    default: result = 32'b0;
                endcase
                if (rd != 5'b0) begin
                    gm_registers[rd] = result;
                    reg_write_happened = 1'b1;
                end
                gm_pc = gm_pc + 32'd4;
        end

        // ---------------- I - TYPE(LOAD) --------------
        7'b0000011: begin
            imm = {{20{instruction[31]}}, instruction[31:20]};
            addr = rs1_val + imm;
            word = gm_memory[addr[11:2]];
            byte_off = addr[1:0];
            case (funct3)
                3'b000: begin // LB
                    case(byte_off)
                        2'b00: result = {{24{word[7]}}, word[7:0]};
                        2'b01: result = {{24{word[15]}}, word[15:8]};
                        2'b10: result = {{24{word[23]}}, word[23:16]};
                        2'b11: result = {{24{word[31]}}, word[31:24]};
                    endcase
                end 
                3'b001: begin // LHW
                    result = (byte_off[1] == 1'b1) ? {{16{word[31]}}, word[31:16]} : {{16{word[15]}}, word[15:0]};
                end

                3'b010: result = word; // LW
                3'b100: begin // LBU
                    case (byte_off)
                        2'b00: result = {24'b0, word[7:0]};
                        2'b01: result = {24'b0, word[15:8]};
                        2'b10: result = {24'b0, word[23:16]};
                        2'b11: result = {24'b0, word[31:24]};
                    endcase
                end
                3'b101: begin // LHU
                    result = (byte_off[1] == 1'b1) ? {16'b0, word[31:16]} : {16'b0, word[15:0]};
                end
                default: result = 32'b0;
            endcase
            if (rd != 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = gm_pc + 32'd4;
        end

        // --------------- STORES ----------------
        7'b0100011: begin
            imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            addr = rs1_val + imm;
            old_word = gm_memory[addr[11:2]];
            byte_off = addr[1:0];
            case (funct3)
                3'b000: begin // SB
                    case (byte_off)
                    2'b00: new_word = {old_word[31:8], rs2_val[7:0]};
                    2'b01: new_word = {old_word[31:16], rs2_val[7:0], old_word[7:0]};
                    2'b10: new_word = {old_word[31:24], rs2_val[7:0], old_word[15:0]};
                    2'b11: new_word = {rs2_val[7:0], old_word[23:0]};
                    endcase
                end
                3'b001: begin // SHW
                    new_word = (byte_off[1] == 1'b1) ? {rs2_val[15:0], old_word[15:0]} : {old_word[31:16], rs2_val[15:0]};
                end
                default: new_word = rs2_val; // SW
            endcase
            gm_memory[addr[11:2]] = new_word;
            gm_pc = gm_pc + 32'd4;
        end

        // --------------- BRANCH ------------------
        7'b1100011: begin
            imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            case (funct3)
            3'b000: take_branch = (rs1_val == rs2_val);
            3'b001: take_branch = (rs1_val != rs2_val);
            3'b100: take_branch = ($signed(rs1_val) < $signed(rs2_val));
            3'b101: take_branch = ($signed(rs1_val) >= $signed(rs2_val));
            3'b110: take_branch = (rs1_val < rs2_val);
            3'b111: take_branch = (rs1_val >= rs2_val);
            default: take_branch = 1'b0;
            endcase
            gm_pc = take_branch ? (gm_pc + imm) : (gm_pc + 32'd4);
        end

        // ----------LUI--------
        7'b0110111: begin
            result = {instruction[31:12], 12'b0};
            if (rd != 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = gm_pc + 32'd4;
        end

        // ----------- AUIPC -----------
        7'b0010111: begin
            result = gm_pc + {instruction[31:12], 12'b0};
            if (rd != 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = gm_pc + 32'd4;
        end

        // ----------- JAL ----------
        7'b1101111: begin
            imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            result = gm_pc + 32'd4;
            if (rd!= 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = gm_pc + imm;
        end

        // ------------ JALR ------------
        7'b1100111: begin
            imm = {{20{instruction[31]}}, instruction[31:20]};
            target = (rs1_val + imm) & ~32'b1;
            result = gm_pc + 32'd4;
            if (rd != 5'b0) begin
                gm_registers[rd] = result;
                reg_write_happened = 1'b1;
            end
            gm_pc = target;
        end

        // ----------- FENCE / ECALL / EBREAK -------------
        7'b0001111, 7'b1110011: begin
            gm_pc = gm_pc + 32'd4;
        end
        
        default: begin
            gm_pc = gm_pc + 32'd4;
        end
        
        endcase
    
        out_rd = rd;
        out_result = result;
        out_reg_write = reg_write_happened;
    endtask

endclass
