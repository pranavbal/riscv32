// and_gate_tb.sv
// Testbench for and_gate

module and_gate_tb;

logic a, b, y;

and_gate uut (
    .a(a),
    .b(b),
    .y(y)
);

initial begin
    a = 0; b = 0; #10;
    $display("a=%b b=%b | y=%b (expect 0)", a, b, y);

    a = 0; b = 1; #10;
    $display("a=%b b=%b | y=%b (expect 0)", a, b, y);

    a = 1; b = 0; #10;
    $display("a=%b b=%b | y=%b (expect 0)", a, b, y);

    a = 1; b = 1; #10;
    $display("a%b b=%b | y=%b (expect 1)", a, b, y);

    $display("Testbench complete.");
    $finish;
end

endmodule