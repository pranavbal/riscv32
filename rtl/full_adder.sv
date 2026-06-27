// full_adder.sv
// add three 1-bit numbers (a, b, cin)
// output is sum and carry out

module full_adder(
    input logic a,
    input logic b,
    input logic cin, 
    output logic sum,
    output logic cout
);

assign sum = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);

endmodule