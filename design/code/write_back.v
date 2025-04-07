module write_back

(
    input wire [31:0] alu,
    input wire [31:0] mem,
    input wire [31:0] pc,
    input wire [1:0]  data_select,
    input wire is_stalled,
    output reg [31:0] wb_out
);
// ALU: I Type R LUI AUIPC B
// PC: JALR, JAL: pc + 4
// Mem: Load
// Default = 0
always @(*) begin
    if (!is_stalled) begin
        case (data_select)
            // ALU
            2'b00: begin
                wb_out = alu;
            end
            // MEM
            2'b01: begin
                wb_out = mem;
            end
            //PC
            default: begin
                wb_out = pc;
            end
        endcase
    end
    
end

endmodule