// instruction_driver.sv
// drives instructions from the sequencer into instruction_memory via (we/waddr/wdata)

class instruction_driver;
    task run(
        ref logic clk,
        ref logic rst,
        ref logic we,
        ref logic [31:0] waddr,
        ref logic [31:0] wdata,
        ref logic [31:0] instr_list [0:9]
    );

    // hold reset for some cycles
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;

    // load each instruction into instruction_memory
    we = 1'b1;
    foreach (instr_list[i]) begin
        waddr = i * 4;
        wdata = instr_list[i];
        @(posedge clk);

    end

    we = 1'b0;
    
    endtask
endclass