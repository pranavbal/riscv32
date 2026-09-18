// golden_model_tb.sv
// Standalone testbench for golden_model.sv - drives fetch via gm_pc so
// the branch skip is respected, matching real hardware fetch behavior

module golden_model_tb;

    golden_model gm;
    logic [31:0] instr_list [0:9];
    logic [4:0] rd_out;
    logic [31:0] result_out;
    logic        reg_write_out;


    initial begin
        gm = new();

        instr_list[0] = 32'h00500093;  // ADDI x1, x0, 5
        instr_list[1] = 32'h00A00113;  // ADDI x2, x0, 10
        instr_list[2] = 32'h002081B3;  // ADD  x3, x1, x2
        instr_list[3] = 32'h40118233;  // SUB  x4, x3, x1
        instr_list[4] = 32'h00402023;  // SW   x4, 0(x0)
        instr_list[5] = 32'h00002283;  // LW   x5, 0(x0)
        instr_list[6] = 32'h00128333;  // ADD  x6, x5, x1
        instr_list[7] = 32'h00108463;  // BEQ  x1, x1, +8
        instr_list[8] = 32'h06300393;  // ADDI x7, x0, 99 (should be skipped)
        instr_list[9] = 32'h04D00413;  // ADDI x8, x0, 77 (branch target)

        // drive fetch off gm_pc, not a flat call sequence, so the BEQ's
        // jump actually skips instruction index 8 like real hardware would
        while (gm.gm_pc < 40) begin
            gm.execute(instr_list[gm.gm_pc >> 2], rd_out, result_out, reg_write_out);
        end

        if (gm.gm_registers[1] !== 5)
            $display("FAIL: x1 = %0d (expect 5)", gm.gm_registers[1]);
        else $display("PASS: x1 = %0d", gm.gm_registers[1]);

        if (gm.gm_registers[2] !== 10)
            $display("FAIL: x2 = %0d (expect 10)", gm.gm_registers[2]);
        else $display("PASS: x2 = %0d", gm.gm_registers[2]);

        if (gm.gm_registers[3] !== 15)
            $display("FAIL: x3 = %0d (expect 15)", gm.gm_registers[3]);
        else $display("PASS: x3 = %0d", gm.gm_registers[3]);

        if (gm.gm_registers[4] !== 10)
            $display("FAIL: x4 = %0d (expect 10)", gm.gm_registers[4]);
        else $display("PASS: x4 = %0d", gm.gm_registers[4]);

        if (gm.gm_registers[5] !== 10)
            $display("FAIL: x5 = %0d (expect 10)", gm.gm_registers[5]);
        else $display("PASS: x5 = %0d", gm.gm_registers[5]);

        if (gm.gm_registers[6] !== 15)
            $display("FAIL: x6 = %0d (expect 15)", gm.gm_registers[6]);
        else $display("PASS: x6 = %0d", gm.gm_registers[6]);

        if (gm.gm_registers[7] !== 0)
            $display("FAIL: x7 = %0d (expect 0, should be skipped)", gm.gm_registers[7]);
        else $display("PASS: x7 = %0d (correctly skipped)", gm.gm_registers[7]);

        if (gm.gm_registers[8] !== 77)
            $display("FAIL: x8 = %0d (expect 77)", gm.gm_registers[8]);
        else $display("PASS: x8 = %0d", gm.gm_registers[8]);

        $display("gm testbench complete.");
        $finish;
    end

endmodule