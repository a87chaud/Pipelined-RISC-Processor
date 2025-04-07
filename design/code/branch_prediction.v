module branch_predictor (
    input clk,
    input reset,
    input [31:0] pc,    
    input branch_outcome,             
    output reg prediction           
);
    reg [1:0] local_history_table [0:1023];
    reg index <= pc[11:2];
    integer i;

    // Reset the table to weakly taken
    always (@posedge reset) begin
        for (i = 0; i < 1024; i = i + 1) begin
            local_history_table[i] = 2'b10;
        end
    end

    // Make prediction
    always (@posedge clk) begin
        if (!reset) begin
            case (local_history_table[index]) 
                2'b00, 2'b01: prediction <= 0;
                2'b10, 2'11: prediction <= 1;
                default: prediction <= 0;
            endcase
        end
    end

    // Update the table based on actual outcome
    always (@posedge clk) begin
        if (!reset) begin
            if (branch_outcome && local_history_table[index] != 2'b11) begin
                local_history_table[index] <= local_history_table[index] + 1;
            end
            else if (!branch_outcome && local_history_table[index] != 2'b00) begin
                local_history_table[index] <= local_history_table[index] - 1;
            end
        end
    end
    endmodule
