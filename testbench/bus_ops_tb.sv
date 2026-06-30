// bus_ops_tb.sv

module bus_ops_tb;
    
    logic msb;
    logic [31:0] data_in;
    logic [7:0] lower_byte;
    logic [31:0] swapped_halves;
    logic [3:0] replicated_bit;


    bus_ops uut(
        .msb(msb),
        .data_in(data_in),
        .lower_byte(lower_byte),
        .swapped_halves(swapped_halves),
        .replicated_bit(replicated_bit)
    );

    initial begin

        data_in = 32'hDEADBEEF; #10;
        $display("data_in=%h | msb=%h | lower_byte=%h | swapped_halves=%h | replicated_bit=%b", data_in, msb, lower_byte, swapped_halves, replicated_bit);

        data_in = 32'h12345678; #10;
        $display("data_in=%h | msb=%h | lower_byte=%h | swapped_halves=%h | replicated_bit=%b", data_in, msb, lower_byte, swapped_halves, replicated_bit);

        data_in = 32'h00000001; #10;
        $display("data_in=%h | msb=%h | lower_byte=%h | swapped_halves=%h | replicated_bit=%b", data_in, msb, lower_byte, swapped_halves, replicated_bit);

        $display("Testbench complete.");
        $finish;

    end

endmodule


