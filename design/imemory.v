module imemory #()
(
    input                       clock,
    input      [31:0]           address,
    input      [31:0]           data_in,
    input                       read_write,
    output reg [31:0]           data_out
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
    end


    always @(*) begin
        if (!read_write) begin
            data_out = {main_mem[address + 3], main_mem[address + 2], main_mem[address + 1], main_mem[address]};
        end
        else begin
            data_out = 32'b0;
        end
    end

    always @(posedge clock) begin
        if (read_write) begin
            main_mem[address]     <= data_in[7:0];
            main_mem[address + 1] <= data_in[15:8];
            main_mem[address + 2] <= data_in[23:16];
            main_mem[address + 3] <= data_in[31:24];
        end
    end
endmodule
