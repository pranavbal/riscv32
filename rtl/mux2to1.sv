 // mux2to1
 // 2 to 1 multiplexer
 // Seelcts between two inputs based on sel signal

 module mux2to1 (
    input logic a,
    input logic b,
    input logic sel,
    output logic y
 );

    assign y = sel ? b : a;

 endmodule

