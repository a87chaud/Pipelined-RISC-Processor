
module decode(
    // input wire [31:0] pc,
    input wire [31:0] data,
    output reg [6:0]  d_opcode,
    // output reg [31:0] d_pc,
    output reg [4:0] d_rd,
    output reg [4:0] d_rs1,
    output reg [4:0] d_rs2,
    output reg [31:0] d_imm,
    output reg [4:0] d_shamt,
    output reg [2:0] d_funct3,
    output reg [6:0] d_funct7
);

always @(data) begin
    d_imm = 0;
    d_funct3 = data[14:12];
    d_funct7 = data[31:25];
    d_rd = data[11:7];
    d_rs1 = data[19:15];
    d_rs2 = data[24:20];
    d_shamt = data[24:20];
    d_opcode = data[6:0];
    // d_pc = pc;
    case (d_opcode)
        // LUI and AUIPIC
        7'b0010111, 7'b0110111: begin
            // d_funct3 = 0;
            // d_rs2  = 0;
            // d_shamt = 0;
            d_rs1  = 0;
            d_imm[31:12] = data[31:12];
            d_imm[11:0] = 0;
        end
        // JAL
        7'b1101111: begin
            // d_funct3 = 0;
            // d_rs1  = 0;
            // d_rs2  = 0;
            // d_shamt = 0;
            // imm[20|10:1|11|19:12] = data[31:12];
            d_imm[20] = data[31];
            d_imm[19:12] = data[19:12];
            d_imm[11] = data[20];
            d_imm[10:1] = data[30:21];
            // check the sign
            if (data[31]) begin
                d_imm[31:21] = 11'hFFF;
            end else begin
                d_imm[31:21] = 11'h000;
            end
        end

        // JALR
        7'b1100111: begin
            // d_rs2  = 0;
            // d_shamt = 0;
            if (data[31]) begin
                d_imm[31:12] = 20'hFFFFF;
            end else begin
                d_imm[31:12] = 20'h00000;
            end
            d_imm[11:0] = data[31:20];
        end
        // BEQ,BNE,BLT,BGE,BLTU,BGEU
        7'b1100011: begin
            // d_rd = 0;
            // d_shamt = 0;
            if (data[31]) begin
                d_imm[31:12] = 20'hFFFFF;
            end else begin
                d_imm[31:12] = 20'h00000;
            end
            d_imm[11] = data[7];
            d_imm[10:5] = data[30:25];
            d_imm[4:1] = data[11:8];
            d_imm[0] = 0;
        end

        // LB, LH, LW, LBU, LHU
        7'b0000011: begin
            // d_shamt = 0;
            // d_rs2 = 0;
            d_imm[11:0] = data[31:20];
            if (data[31]) begin
                d_imm[31:12] = 20'hFFFFF;
            end else begin
                d_imm[31:12] = 20'h00000;
            end
        end

        // SB, SH, SW
        7'b0100011: begin
            // d_rd = 0;
            // d_shamt = 0;
            if (data[31]) begin
                d_imm[31:12] = 20'hFFFFF;
            end else begin
                d_imm[31:12] = 20'h00000;
            end
            d_imm[11:5] = data[31:25];
            d_imm[4:0] = data[11:7];
        end

        7'b0010011: begin
            if (d_funct3[1:0]==2'b01) begin
                // SLLI, SRLI, SRAI
                d_rs2 = 0;
                // d_imm = 0;
                d_funct7 = data[31:25];
                d_shamt = data[24:20];
            end else begin
                // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                // d_shamt = 0;
                d_rs2 = 0;
                if (data[31]) begin
                d_imm[31:12] = 20'hFFFFF;
            end else begin
                d_imm[31:12] = 20'h00000;
            end
                d_imm[11:0] = data[31:20];
            end
        end

        7'b0110011: begin
            // dont do default
        end

        default: begin
            d_imm = 0;
            d_funct3 = 0;
            d_funct7 = 0;
            d_rd = 0;
            d_rs1 = 0;
            d_rs2 = 0;
            d_shamt = 0;
        end
    endcase
end
endmodule;