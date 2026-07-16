// cpu.sv
// Top-level single-cycle RISC-V CPU

module cpu (
    input logic clk,
    input logic rst
    );

    datapath dp (
        .clk(clk),
        .rst(rst)
    );

endmodule
