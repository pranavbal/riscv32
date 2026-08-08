// instruction_memory.sv

module instruction_memory(
    input logic clk,
    input logic we,
    input logic [31:0] waddr,
    input logic [31:0] wdata,
    input logic [31:0] addr,
    output logic [31:0] instruction

);

    // 1024 words each of 32-bits  = 4KB
    logic [31:0] mem [0:1023];

    // Load program from a hex file at simulation start
    initial begin
        $readmemh("program.hex", mem);
    end

    // Write - sequential, driver can inject instructions
    always_ff @(posedge clk) begin
        if (we)
            mem[waddr[11:2]] <= wdata;
    end 
    
    // Read - combinational, instant
    assign instruction = mem[addr[11:2]];

endmodule