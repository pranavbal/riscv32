// mem_stage.sv
// Wraps data_memory for MEM stage

module mem_stage (
    input logic clk,
    input logic we_in,
    input logic [31:0] alu_result_in,
    input logic [31:0] rs2_data_in,
    input logic [2:0] funct3_in,

    output logic [31:0] mem_read_data_out

);

    logic [31:0] raw_mem_read_data;
    logic [31:0] write_data;
    logic [1:0] byte_offset;

    assign byte_offset = alu_result_in[1:0];

    data_memory dmem (
        .clk(clk),
        .we(we_in),
        .addr(alu_result_in),
        .wd(write_data),
        .rd(raw_mem_read_data)
    );

    // Write: read the word in the address, modify it then write it back for SB/SH/SW

    always_comb begin
        case (funct3_in)
            3'b000: begin // SB-replace 1 byte
                case (byte_offset)
                    2'b00: write_data = {raw_mem_read_data[31:8], rs2_data_in[7:0]};
                    2'b01: write_data = {raw_mem_read_data[31:16], rs2_data_in[7:0], raw_mem_read_data[7:0]};
                    2'b10: write_data = {raw_mem_read_data[31:24], rs2_data_in[7:0], raw_mem_read_data[15:0]};
                    2'b11: write_data = {rs2_data_in[7:0], raw_mem_read_data[23:0]};
                    default: write_data = raw_mem_read_data;
                endcase
            end

            3'b001: begin // SH - replace 2 bytes
                case (byte_offset[1])
                    1'b0: write_data = {raw_mem_read_data[31:16], rs2_data_in[15:0]};
                    1'b1: write_data = {rs2_data_in[15:0], raw_mem_read_data[15:0]};
                    default: write_data = raw_mem_read_data;
                endcase
            end
            default: write_data = rs2_data_in; // SW - replace whole word
        endcase
    end

    // Read: extract wanted bytes and extend it
    always_comb begin
        case (funct3_in)
            3'b000: begin // LB - load byte (signed)
                case(byte_offset)
                    2'b00: mem_read_data_out = {{24{raw_mem_read_data[7]}}, raw_mem_read_data[7:0]};
                    2'b01: mem_read_data_out = {{24{raw_mem_read_data[15]}}, raw_mem_read_data[15:8]};
                    2'b10: mem_read_data_out = {{24{raw_mem_read_data[23]}}, raw_mem_read_data[23:16]};
                    2'b11: mem_read_data_out = {{24{raw_mem_read_data[31]}}, raw_mem_read_data[31:24]};
                    default: mem_read_data_out = 32'b0;
                endcase
            end

            3'b001: begin // LH - load halfword (signed)
                case (byte_offset[1])
                    1'b0: mem_read_data_out = {{16{raw_mem_read_data[15]}}, raw_mem_read_data[15:0]};
                    1'b1: mem_read_data_out = {{16{raw_mem_read_data[31]}}, raw_mem_read_data[31:16]};
                    default: mem_read_data_out = 32'b0;
                endcase
            end

            3'b100: begin // LBU - load byte (unsigned)
                case (byte_offset)
                    2'b00: mem_read_data_out = {24'b0, raw_mem_read_data[7:0]};
                    2'b01: mem_read_data_out = {24'b0, raw_mem_read_data[15:8]};
                    2'b10: mem_read_data_out = {24'b0, raw_mem_read_data[23:16]};
                    2'b11: mem_read_data_out = {24'b0, raw_mem_read_data[31:24]};
                    default: mem_read_data_out = 32'b0;
                endcase
            end

            3'b101: begin // LHU - load halfword (unsigned)
                case (byte_offset[1])
                    1'b0: mem_read_data_out = {16'b0, raw_mem_read_data[15:0]};
                    1'b1: mem_read_data_out = {16'b0, raw_mem_read_data[31:16]};
                    default: mem_read_data_out = 32'b0;
                endcase
            end
            default: mem_read_data_out = raw_mem_read_data; // LW - whole word
        endcase
    end

endmodule

