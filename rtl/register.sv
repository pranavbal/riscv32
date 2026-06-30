// register.sv
// 32-bit register with reset

module register #(
    parameter WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

always_ff @(posedge clk) begin
    if (rst)
        q <= '0;
    else
        q <= d;
end
endmodule