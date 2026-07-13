// instruction_memory.sv

module instruction_memory(
    input logic [31:0] addr,
    output logic [31:0] instruction

);

    // 1024 words each of 32-bits  = 4KB
    logic [31:0] mem [0:1023];

    // Load program from a hex file at simulation start
    initial begin
        $readmemh("program.hex", mem);
    end

    // Read - combinational, instant
    assign instruction = mem[addr[11:2]];

endmodule