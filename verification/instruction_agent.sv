// instruction_agent.sv
// Bundles sequencer, driver, and monitor into a reusable unit

class instruction_agent;

    localparam int unsigned MAX_STEPS = 1000;

    instruction_sequencer sqr;
    instruction_driver drv;
    instruction_monitor mon;
    scoreboard sb;
    functional_coverage fc;

    int unsigned exec_count;
    logic [31:0] load_list [$];

    function new();
        sqr = new();
        drv = new();
        mon = new();
        sb = new();
        fc = new();
        exec_count = 0;
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

        logic [31:0] current_instr;
        logic [31:0] pc_before;

        // feed the golden model sequentially
        while (sb.gm.gm_pc < sqr.instr_list.size() * 4 && exec_count < MAX_STEPS) begin
            current_instr = sqr.instr_list[sb.gm.gm_pc >> 2];
            pc_before = sb.gm.gm_pc;                              // PC before this instruction runs
            sb.predict(current_instr);                            // golden model runs it, moves gm_pc
            fc.sample(current_instr, sb.gm.gm_pc != pc_before + 4); // taken = PC didn't go to next instruction
            exec_count++;
        end

        if (sb.gm.gm_pc < $size(sqr.instr_list) * 4) begin
            $error("Golden model hit MAX_STEPS (%0d) before reaching end of program", MAX_STEPS);
        end

        load_list = sqr.instr_list;
        while (load_list.size() < 16) load_list.push_back(32'h00000013);

        fork
            drv.run(clk, rst, we, waddr, wdata, load_list);
            mon.run(clk, wb_rd_addr, wb_write_data, wb_reg_write, sb);
        join_none

    endtask

endclass