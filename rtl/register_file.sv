// register_file.sv

module register_file (
    input logic clk,
    input logic rst,
    input logic reg_write,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    input logic [31:0] rd_data

);

    // 32 registers each 32 bits wide
    logic [31:0] registers[0:31];

    // Read port 1 - combinational
    assign rs1_data = (rs1_addr == 5'b00000) ? 32'b0 : 
                        (reg_write && rd_addr == rs1_addr) ? rd_data : 
                        registers[rs1_addr];

    // Read port 2 - combinational
    assign rs2_data = (rs2_addr == 5'b00000) ? 32'b0 : 
                        (reg_write && rd_addr == rs2_addr) ? rd_data : 
                        registers[rs2_addr];

    // Write port - sequential (on clock edge)

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end
        else if (reg_write && rd_addr != 5'b00000) begin
            registers[rd_addr] <= rd_data;

        end
    end
endmodule

    
