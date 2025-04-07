module dmemory #()
(
    input wire clock,
    input wire [1:0] access_size,
    input wire [31:0] m_address,
    input wire signed [31:0] m_data_in,
    input wire m_rw,
    input wire is_signed,
    output reg[31:0] m_data_out
);

reg [7:0] main_mem[0: `MEM_DEPTH-1];
reg [31:0] temp_mem[0: `LINE_COUNT-1];

integer i;

initial begin
    $readmemh(`MEM_PATH, temp_mem);
    for (i = 0; i < `LINE_COUNT; i = i + 1) begin
        main_mem[i*4]     = temp_mem[i][7:0];
        main_mem[i*4 + 1] = temp_mem[i][15:8];
        main_mem[i*4 + 2] = temp_mem[i][23:16];
        main_mem[i*4 + 3] = temp_mem[i][31:24];
    end
    m_data_out = 32'b0;
end

// LOAD
always @(*) begin
    if (!m_rw) begin
        case (access_size)
            2'b00:begin
                m_data_out[7:0]= main_mem[m_address];
                if (is_signed && main_mem[m_address][7]) begin
                    m_data_out[31:8] = 24'hFFFFFF;
                end else begin
                    m_data_out[31:8] = 0;
                end
            end
            2'b01: begin
                m_data_out[7:0] = main_mem[m_address];
                m_data_out[15:8] = main_mem[m_address + 1];
                if (is_signed && main_mem[m_address + 1][7]) begin
                    m_data_out[31:16] = 16'hFFFF;
                end else begin
                    m_data_out[31:16] = 0;
                end
            end
            2'b10: begin
                m_data_out[7:0] = main_mem[m_address];
                m_data_out[15:8] = main_mem[m_address + 1];
                m_data_out[23:16] = main_mem[m_address + 2];
                m_data_out[31:24] = main_mem[m_address + 3];
            end
            default: begin
                m_data_out = 0;
            end
        endcase
    end else begin
        m_data_out = 0;
    end
end

// STORE
always @(posedge clock) begin
    if (m_rw)begin
        case (access_size)
            2'b00: begin
                main_mem[m_address] = m_data_in[7:0];
            end
            2'b01: begin
                main_mem[m_address] = m_data_in[7:0];
                main_mem[m_address + 1] = m_data_in[15:8];
            end
            2'b10: begin
                main_mem[m_address] = m_data_in[7:0];
                main_mem[m_address + 1] = m_data_in[15:8];
                main_mem[m_address + 2] = m_data_in[23:16];
                main_mem[m_address + 3] = m_data_in[31:24];
            end
            default: begin
                // do nothing
            end
        endcase
    end
end

endmodule
