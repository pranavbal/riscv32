// instruction_driver.sv
// drives instructions from the sequencer into instruction_memory via (we/waddr/wdata)

class instruction_driver;
    task run(
        ref logic clk,
        ref logic rst,
        ref logic we,
        ref logic [31:0] waddr,
        ref logic [31:0] wdata,
        input logic [31:0] instr_list [$]
    );

    // hold reset while loading instructions
    rst = 1'b1;
    we = 1'b1;

    // load each instruction into instruction_memory
    foreach (instr_list[i]) begin
        @(negedge clk);
        waddr = i * 4;
        wdata = instr_list[i];
    end

    // wait until last instruction is written
    @(negedge clk);
    we = 1'b0;

    // release reset after all instructions are loaded
    rst = 1'b0;
    
    endtask
endclass