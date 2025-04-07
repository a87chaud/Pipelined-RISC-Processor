module alu #()
(
    input [31:0] pc,
    input [31:0] a,
    input [31:0] b,
    input  [3:0] alu_select,
    output reg signed [31:0] alu_result
);

always @(*) begin
    if (pc == 32'h01000018) begin
        // $display("ALU: a = %h, b = %h, alu_select = %h", a, b, alu_select);
    end
    case (alu_select)
        // 4'b0000: alu_result = a + b;
        4'b0000: alu_result = $signed(a) + $signed(b);
        4'b0001: alu_result = $signed(a) - $signed(b);
        4'b0010: alu_result = a & b;
        4'b0011: alu_result = a | b;
        4'b0100: alu_result = a ^ b;
        4'b0101: alu_result = a << b[4:0];
        4'b0110: alu_result = a >> b[4:0];
        // Signed operations
        4'b0111: alu_result = $signed(a) >>> b[4:0];
        4'b1000: alu_result = $signed(a) <<< b[4:0];
        // Extra operations
        4'b1001: alu_result = (a + (b << 12));
        4'b1010: alu_result = ($signed(a) < $signed(b)) ? 32'h00000001 : 0;
        4'b1011: alu_result = (a < b) ? 32'h00000001 : 0;


        default: alu_result = 0;
    endcase

end
endmodule