// hald_adder_tb.sv

module half_adder_tb;
    logic a, b, sum, carry;



half_adder uut(
    .a(a),
    .b(b),
    .sum(sum),
    .carry(carry)

);

initial begin
    // testing all 4 combinations

    a = 0; b = 0; #10;
    $display("a=%b b=%b | sum=%b carry=%b (expect sum = 0 carry = 0)", a, b, sum, carry);

    a = 0; b = 1; #10;
    $display("a=%b b=%b | sum=%b carry=%b (expect sum = 1 carry = 0)", a, b, sum, carry);

    a = 1; b = 0; #10;
    $display("a=%b b=%b | sum=%b carry=%b (expect sum = 1 carry = 0)", a, b, sum, carry);

    a = 1; b = 1; #10;
    $display("a=%b b=%b | sum=%b carry=%b (expect sum = 0 carry = 1)", a, b, sum, carry);
    $display("Testbench complete");
    $finish;

end
endmodule


