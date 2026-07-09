// alu_tb.sv

module alu_tb;
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] alu_control;
    logic [31:0] result;
    logic zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
        
    );

    initial begin
        //ADD
        a = 32'd10 ; b = 32'd20 ; alu_control = 4'b0000; #10;
        $display("ADD: %0d + %0d = %0d (expect 30)", a, b, result);

        //SUB
        a = 32'd20; b = 32'd10; alu_control = 4'b0001; #10;
        $display("SUB: %0d - %0d = %0d (expect 10)", a, b, result);

        //AND
        a = 32'hF0; b = 32'hFF; alu_control = 4'b0010; #10;
        $display("AND: %h & %h = %h (expect f0)", a, b, result);

        //OR
        a = 32'hF0; b = 32'hFF; alu_control = 4'b0011; #10;
        $display("OR: %h | %h = %h (expect ff)", a, b, result);

        //XOR
        a = 32'hFF; b = 32'hFF; alu_control = 4'b0100; #10;
        $display("XOR: %h ^ %h = %h (expect 00)", a, b, result);

        //SLL
        a = 32'd1; b = 32'd4; alu_control = 4'b0101; #10;
        $display("SLL: %0d << %0d = %0d (expect 16)", a, b, result);

        //SRL
        a = 32'd16; b = 32'd2; alu_control = 4'b0110; #10;
        $display("SRL: %0d >> 2 = %0d (expect 4)", a, result);

        //SRA
        a = 32'hFFFFFFF8; b = 32'd1; alu_control = 4'b0111; #10;
        $display("SRA: %0d >>> %0d = %0d (expect -4)", $signed(a), $signed(b), $signed(result));

        //SLT: 
        a = 32'hFFFFFFFF; b = 32'd1; alu_control = 4'b1000; #10;
        $display("SLT: %0d < %0d = %0d (expect 1)", $signed(a), $signed(b), result);

        //SLTU:
        a = 32'hFFFFFFFF; b = 32'd1; alu_control = 4'b1001; #10;
        $display("SLTU: %0d < %0d = %0d (expect 0)", a, b, result);

        // Zero flag
        a = 32'd5; b = 32'd5; alu_control = 4'b0001; #10;
        $display("ZERO FLAG: %0d - %0d = %0d | zero=%b (expect 1)", a, b, result, zero);

        $display("Testbench complete.");
        $finish;
    end
endmodule


