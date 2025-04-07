module controller(
    input wire [31:0] pc,
    input wire [31:0] data,
    input reg  [6:0]  d_opcode,
    // Decoded Address of rs1 and rs2
    input reg  [4:0] d_rs1,
    input reg  [4:0] d_rs2,
    input reg mx_rs1_flag,
    input reg mx_rs2_flag,
    input reg [31:0] mx_data_forwarded,
    input reg wx_rs1_flag,
    input reg wx_rs2_flag,
    input reg [31:0] wx_data_forwarded,
    // Data stored in rs1 and rs2 for all operations
    input reg signed [31:0] data_rs1,
    input reg signed [31:0] data_rs2,
    input reg  [31:0] d_imm,
    input reg   [4:0] d_shamt,
    input reg  [2:0] d_funct3,
    input reg  [6:0] d_funct7,
    output reg [3:0] alu_select,
    output reg signed [31:0] a,
    output reg signed [31:0] b,
    output reg  branch_taken,
    output reg  write_enable,
    output reg is_signed,
    output reg [1:0] access_size,
    output reg dmem_rw,
    output reg [1:0] wb_select,
    output reg jump
);

reg [31:0] data_rs1_reg;
reg [31:0] data_rs2_reg;

always @(mx_rs1_flag, mx_rs2_flag, wx_rs1_flag, wx_rs2_flag) begin
    if (mx_rs1_flag & mx_rs2_flag) begin
        data_rs1_reg = mx_data_forwarded;
        data_rs2_reg = mx_data_forwarded;
    end else if (mx_rs1_flag & wx_rs2_flag) begin
        data_rs1_reg = mx_data_forwarded;
        data_rs2_reg = wx_data_forwarded;
    end else if (wx_rs1_flag & mx_rs2_flag) begin
        data_rs1_reg = wx_data_forwarded;
        data_rs2_reg = mx_data_forwarded;
    end else if (wx_rs1_flag & wx_rs2_flag) begin
        data_rs1_reg = wx_data_forwarded;
        data_rs2_reg = wx_data_forwarded;
    end else if (mx_rs1_flag) begin
        data_rs1_reg = mx_data_forwarded;
        data_rs2_reg = data_rs2;
    end else if (mx_rs2_flag) begin
        data_rs1_reg = data_rs1;
        data_rs2_reg = mx_data_forwarded;
    end else if (wx_rs1_flag) begin
        data_rs1_reg = wx_data_forwarded;
        data_rs2_reg = data_rs2;
    end else if (wx_rs2_flag) begin
        data_rs1_reg = data_rs1;
        data_rs2_reg = wx_data_forwarded;
    end else begin
        data_rs1_reg = data_rs1;
        data_rs2_reg = data_rs2;
    end
end



always @(data) begin
    branch_taken = 0;
    write_enable = 0;
    is_signed= 1;
    dmem_rw = 0;
    case (d_opcode)
        // LUI
        7'b0110111: begin
            write_enable = 1;
            wb_select = 2'b00;
            a[19:0] = d_imm[31:12];
            b = 12;
            alu_select = 4'b0101;
        end
        // AUIPIC
        7'b0010111: begin
            write_enable = 1;
            wb_select = 2'b00;
            a = pc;
            b = d_imm;
            alu_select = 4'b0000;
        end

        // JAL
        7'b1101111: begin
            write_enable = 1;
            wb_select = 2'b10;
            jump = 1;
            a = pc;
            b = d_imm;
            alu_select = 4'b0000;
        end

        // JALR
        7'b1100111: begin
            write_enable = 1;
            wb_select = 2'b10;
            is_signed = 1;
            jump = 1;
            a = data_rs1_reg;
            b = d_imm;
            alu_select = 4'b0000;
            // if (pc == 32'h010000d8) begin
            //     $display("JALR_controller: a = %h, b = %h, wx_flag = %h", data_rs1_reg, b, wx_rs1_flag);
            // end
        end

        // BEQ,BNE,BLT,BGE,BLTU,BGEU
        7'b1100011: begin
            // NOT SURE(PC/ALU)
            write_enable = 0;
            wb_select = 2'b00;
            case(d_funct3)
                // BEQ
                3'b000: begin
                    if (data_rs1_reg == data_rs2_reg) begin
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                // BNE
                3'b001: begin
                    // $display("BEQ");
                    if (data_rs1_reg != data_rs2_reg) begin
                        // $display(d_rs1);
                        // $display(d_rs2);
                        // $display(pc);
                        // $display(d_imm);
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                // BLT
                3'b100: begin
                    if ($signed(data_rs1_reg) < $signed(data_rs2_reg)) begin
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                // BGE
                3'b101: begin
                    if ($signed(data_rs1_reg) >= $signed(data_rs2_reg)) begin
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                // BLTU
                3'b110: begin
                    if (data_rs1_reg < data_rs2_reg) begin
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                // BGEU
                3'b111: begin
                    if (data_rs1_reg >= data_rs2_reg) begin
                        branch_taken = 1;
                    end
                    a = pc;
                    b = d_imm;
                    alu_select = 4'b0000;
                end
                default: begin
                    a = 0;
                    b = 0;
                    alu_select = 0;
                end
            endcase
        end

        // LB, LH, LW, LBU, LHU
        7'b0000011: begin
            write_enable = 1;
            dmem_rw = 0;
            wb_select =2'b01;
            case (d_funct3)
                3'b000: begin
                    access_size =2'b00;
                end
                3'b001: begin
                    access_size = 2'b01;
                end
                3'b010: begin
                    access_size = 2'b10;
                end
                3'b100: begin
                    access_size = 2'b00;
                    is_signed = 0;
                end
                3'b101: begin
                    access_size = 2'b01;
                    is_signed = 0;
                end
                default: begin
                    // do nothing
                end
            endcase
            a = data_rs1_reg;
            b = d_imm;
            alu_select = 4'b0000;
        end
        // SB, SH, SW
        7'b0100011: begin
            wb_select = 2'b01;
            case (d_funct3)
                3'b000: begin
                    access_size =2'b00;
                end
                3'b001: begin
                    access_size = 2'b01;
                end
                3'b010: begin
                    access_size = 2'b10;
                end
                default: begin
                    // do nothing
                end
            endcase
            a = data_rs1_reg;
            b = d_imm;
            alu_select = 4'b0000;
            write_enable = 0;
            dmem_rw = 1;
        end

        7'b0010011: begin
            write_enable = 1;
            wb_select = 2'b00;
            if (d_funct3[1:0]==2'b01) begin
                // SLLI, SRLI, SRAI
                case(d_funct3)
                    // SLLI
                    3'b001: begin
                        a = data_rs1_reg;
                        b[4:0] = d_shamt;
                        alu_select = 4'b0101;
                    end
                    3'b101: begin
                        case(d_funct7)
                            // SRLI
                            7'b0000000: begin
                                a = data_rs1_reg;
                                b[4:0] = d_shamt;
                                alu_select = 4'b0110;
                            end
                            // SRAI
                            7'b0100000: begin
                                a = data_rs1_reg;
                                b[4:0] = d_shamt;
                                alu_select = 4'b0111;
                            end

                            default: begin
                                a = 0;
                                b = 0;
                                alu_select = 0;
                            end

                        endcase
                    end
                    default: begin
                        a = 0;
                        b = 0;
                        alu_select = 0;
                    end
                endcase

            end else begin
                // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
                wb_select = 2'b00;

                case(d_funct3)
                    // ADDI
                    3'b000: begin
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b0000;
                    end
                    // SLTI
                    3'b010: begin
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b1010;
                    end
                    // SLTIU
                    3'b011: begin
                        // if (data_rs1_reg < data_rs2_reg) begin
                        //     branch_taken = 1;
                        // end else begin
                        //     branch_taken = 0;
                        // end
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b1011;
                    end
                    // XORI
                    3'b100: begin
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b0100;
                    end
                    // ORI
                    3'b110: begin
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b0011;
                    end
                    // ANDI
                    3'b111: begin
                        a = data_rs1_reg;
                        b = d_imm;
                        alu_select = 4'b0010;
                    end
                    default: begin
                        a = 0;
                        b = 0;
                        alu_select = 0;
                    end
                endcase
            end
        end

        7'b0110011: begin
            is_signed = 1;
            wb_select = 2'b00;
            write_enable = 1;
            case (d_funct3)
                3'b000: begin
                    case(d_funct7)
                        // ADD
                        7'b0000000: begin
                            a = data_rs1_reg;
                            b = data_rs2_reg;
                            alu_select = 4'b0000;
                        end
                        // SUB
                        7'b0100000: begin
                            a = data_rs1_reg;
                            b = data_rs2_reg;
                            alu_select = 4'b0001;
                        end
                        default: begin
                            a = 0;
                            b = 0;
                            alu_select = 0;
                        end
                    endcase
                end
                // SLL
                3'b001: begin
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b0101;
                end
                // SLT
                3'b010: begin
                    // if ($signed(data_rs1_reg) < $signed(data_rs2_reg)) begin
                    //     a = 1;
                    // end else begin
                    //     a = 0;
                    // end
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b1010;
                end
                // SLTU
                3'b011: begin
                    // if (data_rs1_reg < data_rs2_reg) begin
                    //     a = 1;
                    // end else begin
                    //     a = 0;
                    // end
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b1011;
                end
                // XOR
                3'b100: begin
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b0100;
                end
                // SRL, SRA
                3'b101: begin
                    case(d_funct7)
                    7'b0000000: begin
                        a = data_rs1_reg;
                        b = data_rs2_reg;
                        alu_select = 4'b0110;
                    end
                    7'b0100000: begin
                        a = data_rs1_reg;
                        b = data_rs2_reg;
                        alu_select = 4'b0111;
                    end
                    default: begin
                        a = 0;
                        b = 0;
                        alu_select = 0;
                    end
                    endcase
                end
                // OR
                3'b110: begin
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b0011;
                end
                // AND
                3'b111: begin
                    a = data_rs1_reg;
                    b = data_rs2_reg;
                    alu_select = 4'b0010;
                end
                default: begin
                    a = 0;
                    b = 0;
                    alu_select = 0;
                end
            endcase
        end
        default: begin
            a = 0;
            b = 0;
            alu_select = 0;
        end
    endcase
end
endmodule;