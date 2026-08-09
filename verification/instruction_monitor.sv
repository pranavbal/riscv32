// instruction_monitor.sv
// watches write-back signals every cycle and packages them into 
// instruction_transaction objects

class instruction_monitor;

    task run(
        ref logic clk,
        ref logic [4:0] wb_rd_addr,
        ref logic [31:0] wb_write_data,
        ref logic wb_reg_write
    );

    instruction_transaction tx;

    forever begin
        @(posedge clk);
        if (wb_reg_write) begin
            tx = new();
            tx.rd_addr = wb_rd_addr;
            tx.write_data = wb_write_data;
            tx.reg_write = wb_reg_write;
            $display("Monitor observed: rd=x%0d data=%0d", tx.rd_addr, tx.write_data);
        end
    end
    endtask
    
endclass