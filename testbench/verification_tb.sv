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
        agent.run(clk, rst, we, waddr, wdata, wb_rd_addr, wb_write_data, wb_reg_write);

        // let simulation run long enough for driver load + program execution
        repeat (50) @(posedge clk);

        $display("Verification testbench complete.");
        $finish;
    end

endmodule

