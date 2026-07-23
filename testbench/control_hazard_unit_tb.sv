// control_hazard_unit_tb.sv

module control_hazard_unit_tb;
    logic idex_branch;
    logic ex_zero;
    logic idex_jump;
    logic flush;

    control_hazard_unit uut (
        .idex_branch(idex_branch),
        .ex_zero(ex_zero),
        .idex_jump(idex_jump),
        .flush(flush)

    );

    initial begin
        // Test 1: jump - should flush
        idex_branch = 0;
        idex_jump = 1;
        ex_zero = 1;
        #1;
        $display("Test 1 | flush=%b", flush);
        $display("expect: flush=1");

        // Test 2: branch taken (zero = 1) - should flush
        idex_branch = 1;
        idex_jump = 0;
        ex_zero = 1;
        #1;
        $display("Test 2 | flush=%b", flush);
        $display("expect: flush=1");

        // Test 3: branch not taken (zero = 1) - shouldn't flush
        idex_branch = 1;
        idex_jump = 0;
        ex_zero = 0;
        #1;
        $display("Test 3 | flush=%b", flush);
        $display("expect: flush=0");

        // Test 3: neither branch nor jump - shouldn't flush
        idex_branch = 0;
        idex_jump = 0;
        ex_zero = 0;
        #1;
        $display("Test 4 | flush=%b", flush);
        $display("expect: flush=0");

        $display("Testbench complete.");
        $finish;
    end
endmodule 

