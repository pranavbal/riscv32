module bus_ops (
    input logic [31:0] data_in,
    output logic        msb,
    output logic [7:0] lower_byte,
    output logic [31:0] swapped_halves,
    output logic [3:0] replicated_bit
);

// bit selection - grab bit 31

assign msb = data_in[31];

// slicing - grab bits 7 to 0

assign lower_byte = data_in[7:0];

// concatenation - swap the two 16-bit halves

assign swapped_halves =  {data_in[15:0], data_in[31:16]};

// replication - repeat bit 0 four times

assign replicated_bit  = {4{data_in[0]}};

endmodule

