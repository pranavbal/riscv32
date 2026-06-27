// mux2to1_tb.sv
// Testbench for 2-to-1 MUX

module mux2to1_tb;

logic a, b, sel, y;

mux2to1 uut(
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)


);


initial begin 
    // sel=0 should output a
       a = 0; b = 1; sel = 0; #10;
    $display("a=%b b=%b sel=%b | y=%b (expect 0)", a, b, sel, y);

       a = 1; b = 0; sel = 0; #10;
    $display("a=%b b=%b sel=%b | y=%b (expect 1)", a, b, sel, y);

       a = 0; b = 1; sel = 1; #10;
    $display("a=%b b=%b sel=%b | y=%b (expect 1)", a, b, sel, y);

       a = 1; b = 0; sel = 1; #10;
       $display("a=%b b=%b sel=%b | y=%b (expect 0)", a, b, sel, y);
       $display("Testbench complete.");
       $finish;
end

endmodule
