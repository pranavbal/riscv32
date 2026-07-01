// ripple_carry_adder_tb.sv

module ripple_carry_adder_tb;
    logic cin, cout;
    logic [3:0] a, b, sum;

    ripple_carry_adder uut (
        .cin(cin),
        .cout(cout),
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        a = 4'b0001; b = 4'b0001; cin = 0; #10;
        $display("a=%b | b = %b | cin = %b | sum=%b | cout = %b | (expect sum = 0010 cout = 0)", a, b, cin, sum, cout);

        a = 4'b1111; b = 4'b0001; cin = 0; #10;
        $display("a=%b | b = %b | cin = %b | sum=%b | cout = %b | (expect sum = 0000 cout = 1)", a, b, cin, sum, cout);

        a = 4'b1111; b = 4'b1111; cin = 0; #10;
        $display("a=%b | b = %b | cin = %b | sum=%b | cout = %b | (expect sum = 1110 cout = 1)", a, b, cin, sum, cout);
        $display("Testbench complete");
        $finish;
    end
endmodule

    

    
