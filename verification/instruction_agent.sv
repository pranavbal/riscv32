// instruction_agent.sv
// Bundles sequencer, driver, and monitor into a reusable unit

class instruction_agent;

    instruction_sequencer sqr;
    instruction_driver drv;
    instruction_monitor mon;
    scoreboard sb;
    functional_coverage fc;

    function new();
        sqr = new();
        drv = new();
        mon = new();
        sb = new();
        fc = new();
    endfunction

    task run(
        ref logic clk,
        ref logic rst,
        ref logic we,
        ref logic [31:0] waddr,
        ref logic [31:0] wdata,
        ref logic [4:0] wb_rd_addr,
        ref logic [31:0] wb_write_data,
        ref logic wb_reg_write
    );
        // feed the golden model sequentially
        // avoids  xSim's ref-in-form limitation
        while (sb.gm.gm_pc < 40) begin
            sb.predict(sqr.instr_list[sb.gm.gm_pc >> 2]);
            fc.sample(sqr.instr_list[sb.gm.gm_pc >> 2]);
        end

        fork
            drv.run(clk, rst, we, waddr, wdata, sqr.instr_list);
            mon.run(clk, wb_rd_addr, wb_write_data, wb_reg_write, sb);
        join_none

    endtask

endclass