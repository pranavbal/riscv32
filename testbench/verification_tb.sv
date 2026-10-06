// verification_tb.sv
// TOp-level testbench: runs the sequencer, drive, DUT, monitor chain

module verification_tb;

    logic clk;
    logic rst;
    logic we;
    logic [31:0] waddr;
    logic [31:0] wdata;

    logic [4:0] wb_rd_addr;
    logic [31:0] wb_write_data;
    logic        wb_reg_write;

    int n_r, n_i, n_sh, n_lui, n_auipc;

    // clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // DUT instantiation
    cpu_pipeline uut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .wb_write_back_addr_out(wb_rd_addr),
        .wb_write_back_data_out(wb_write_data),
        .wb_reg_write_final_out(wb_reg_write)
    );

    instruction_agent agent;

    initial begin
        agent = new();
        agent.sqr.load_random(100, 3); // 10 random instructions with different seeds
        
        // counters for each instruction kind

        // count kinds
        foreach (agent.sqr.instr_list[i]) begin
            if (i >= 8) begin
                case (agent.sqr.instr_list[i][6:0])
                    7'b0110011: n_r++;
                    7'b0010011: begin
                        if (agent.sqr.instr_list[i][14:12] inside {3'b001, 3'b101}) n_sh++;
                        else n_i++;
                        end
                    7'b0110111: n_lui++;
                    7'b0010111: n_auipc++;
                endcase
            end
        end

            $display("KINDS: R=%0d I=%0d SHIFT=%0d LUI=%0d AUIPC=%0d", n_r, n_i, n_sh, n_lui, n_auipc);
        agent.run(clk, rst, we, waddr, wdata, wb_rd_addr, wb_write_data, wb_reg_write);

        // wait for load cycles + 3 cycles per instruction + buffer
        repeat (agent.sqr.instr_list.size() + 3 * agent.exec_count + 20) @(posedge clk);

        $display("Verification testbench complete.");
        $display("Instruction coverage: %0.2f%%", agent.fc.instruction_coverage.get_coverage());
        $finish;
    end

endmodule

