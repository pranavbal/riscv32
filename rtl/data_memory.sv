// data_memory.sv

module data_memory(
    input logic clk,
    input logic we,
    input logic [31:0] addr,
    input logic [31:0] wd,
    output logic [31:0] rd
);

    // 1024 words of 32-bit memory = 4KB
    logic [31:0] mem [0:1023];

    // Write - sequential
    always_ff @(posedge clk) begin
        if (we)
            mem[addr[11:2]] <= wd;
    end

    // Read - combinational
    assign rd = mem[addr[11:2]];
endmodule

