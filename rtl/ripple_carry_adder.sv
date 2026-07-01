// ripple_carry_adder.sv
// 4-bit ripple carry adder
// made from full-adder modules chained together

module ripple_carry_adder (
    input logic cin,
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [3:0] sum,
    output logic cout
);

    //internal carry signals connecting the adders
    logic c1, c2, c3;

    //Bit 0 or LSB
    full_adder fa0 (
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(c1)
    );

    // Bit 1
    full_adder fa1 (
        .a(a[1]),
        .b(b[1]),
        .cin(c1),
        .sum(sum[1]),
        .cout(c2)
    );

    // Bit 2
     full_adder fa2 (
        .a(a[2]),
        .b(b[2]),
        .cin(c2),
        .sum(sum[2]),
        .cout(c3)
    );

    // Bit 3 or MSB
     full_adder fa3 (
        .a(a[3]),
        .b(b[3]),
        .cin(c3),
        .sum(sum[3]),
        .cout(cout)
    );

endmodule