module register_file #()
(
    input wire [31:0] data_rd,
    input wire [4:0] addr_rd,
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire clock,
    input wire reset,
    input wire write_enable,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2
);

reg [31:0] data [0:31];
integer i = 0;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        if (i == 2) begin
            data[i] = 32'h01000000 + `MEM_DEPTH;
        end
        else begin
            data[i] = 0;
        end
    end 
end
// Reading
always @(addr_rs1 or addr_rs2) begin
    data_rs1 = data[addr_rs1];
    data_rs2 = data[addr_rs2];
end

// Writing
always @(posedge clock) begin
    if(reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            if (i == 2) begin
                data[i] = 32'h01000000 + `MEM_DEPTH;
            end
            else begin
                data[i] = 0;
            end
        end 
    end
    else if (write_enable && addr_rd != 0) begin
        data[addr_rd] <= data_rd;
    end

end

endmodule

