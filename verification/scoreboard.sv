// scoreboard.sv
// compares the real CPU's behavior (using monitor) against 
// the golden model's prediction using FIFO queue

class scoreboard;

    golden_model gm;
    instruction_transaction pending_predictions [$];
    int pass_count;
    int fail_count;

    function new();
        gm = new();
        pass_count = 0;
        fail_count = 0;
    endfunction

    // called when an instruction is sent - feeds it to goldenm model
    // queues the prediction in pending_predictions queue

    task predict(logic [31:0] instruction);
        logic [4:0] rd_out;
        logic [31:0] result_out;
        logic        reg_write_out;
        instruction_transaction tx;

        gm.execute(instruction, rd_out, result_out, reg_write_out);
              
        if (reg_write_out) begin
            tx = new();
            tx.rd_addr = rd_out;
            tx.write_data = result_out;
            pending_predictions.push_back(tx);
        end
    endtask

    // Called when monitor observers write-back
    // pops the oldest prediction(now at front because each new prediction pushes new to back)
    // compares the popped prediction to what was observed from cpu

    task check(logic [4:0] observed_rd, logic [31:0] observed_data, logic observed_reg_write);
        instruction_transaction expected;

        if(!observed_reg_write) return;

        if (pending_predictions.size() == 0) begin
            $display("SCOREBOARD ERROR: observed a write but no prediction was queued");
            fail_count++;
            return;
        end

        expected = pending_predictions.pop_front();

        if (expected.rd_addr == observed_rd && expected.write_data == observed_data) begin
            $display("SCOREBOARD PASS: rd=x%0d data=%0d", observed_rd, observed_data);
            pass_count++;
        end else begin
            $display("SCOREBOARD FAIL: expected rd=x%0d data=%0d, observed rd=x%0d data=%0d", expected.rd_addr, expected.write_data, observed_rd, observed_data);
            fail_count++;
        end
    endtask
endclass
        

