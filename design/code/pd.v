module pd(
  input                      clock,
  input                      reset
);

  reg [31: 0]  pc = 32'h01000000;
  reg [31: 0]  instruction;
  reg  branch_taken;
  reg signed [31:0] alu_result;
  reg stall = 0;
  reg jump = 0;

  always @(posedge clock) begin
    if (reset) begin
      pc <= 32'h01000000;
    end
    else if (!stall && !jump && !branch_taken) begin
      pc <= pc + 4;
    end else if (jump || branch_taken) begin
      pc <= alu_result;
    end
  end

  imemory imem1 (
  .clock(clock),
  .address(pc),
  .data_in(32'b0),
  .data_out(instruction),
  .read_write(1'b0)
  );

  reg [2: 0]  d_funct3;
  reg [31: 0] d_imm;
  reg [4: 0]  d_rd;
  reg [4: 0]  d_rs1;
  reg [4: 0]  d_rs2;
  reg [4: 0]  d_shamt;
  reg [6: 0]  d_funct7;
  reg [6: 0]  d_opcode;

  decode decode1 (
  .data(d_instruction),
  .d_opcode(d_opcode),
  .d_rd(d_rd),
  .d_rs1(d_rs1),
  .d_rs2(d_rs2),
  .d_imm(d_imm),
  .d_shamt(d_shamt),
  .d_funct3(d_funct3),
  .d_funct7(d_funct7)
  );

  always @(*) begin
    stall = 0;
    if (e_opcode == 7'b0000011) begin
      if (((d_rs1 == e_rd) || ((d_rs2 == e_rd) && (d_opcode != 7'b0100011))) && (e_rd != 0)) begin
        stall = 1;
      end
    end

    //load use
    if ((w_rd == d_rs1 || ((w_rd == d_rs2) && (d_opcode != 7'b0000011))) && (w_rd != 0) && (((w_rd!=m_rd) && (w_pc!=m_pc)) || (m_opcode == 7'b0100011) || (m_opcode == 7'b1100011)) && (((w_rd!=e_rd) && (w_pc!=e_pc)) || (e_opcode == 7'b0100011) || (e_opcode == 7'b1100011)) && !w_branch_taken && (d_opcode != 7'b0110111) && (d_opcode != 7'b0010111)) begin
      stall = 1;
    end
    
    if (e_opcode == 7'b1101111 || e_opcode ==  7'b1100111) begin
      jump = 1;
    end else begin
      jump = 0;
    end

  end

  reg [3:0] alu_select;
  reg  signed [31:0] a;
  reg  signed [31:0] b;
  reg  write_enable;

  reg signed [31:0] w_data_rd;
  reg signed [31:0] w_data_rd_prev;
  reg signed [4:0] w_rd_prev;
  reg signed [31:0] data_rs1;
  reg signed [31:0] data_rs2;
  reg is_signed_controller;
  reg [1:0] access_size_controller;
  reg dmem_rw;
  reg [1:0] wb_select;

  controller controller1(
    .pc(e_pc),
    .data(e_instruction),
    .d_opcode(e_opcode),
    .d_rs1(e_rs1),
    .d_rs2(e_rs2),
    .mx_rs1_flag(mx_rs1_flag),
    .mx_rs2_flag(mx_rs2_flag),
    .mx_data_forwarded(mx_data_forwarded),
    .wx_rs1_flag(wx_rs1_flag),
    .wx_rs2_flag(wx_rs2_flag),
    .wx_data_forwarded(wx_data_forwarded),
    .data_rs1(e_data_rs1),
    .data_rs2(e_data_rs2),
    .d_imm(e_imm),
    .d_shamt(e_shamt),
    .d_funct3(e_funct3),
    .d_funct7(e_funct7),
    .alu_select(e_alu_select),
    .a(e_a),
    .b(e_b),
    .branch_taken(branch_taken),
    .write_enable(write_enable),
    .is_signed(is_signed_controller),
    .access_size(access_size_controller),
    .dmem_rw(dmem_rw),
    .wb_select(wb_select),
    .jump(jump)
  );

  alu alu1 (
    .pc(e_pc),
    .a(e_a),
    .b(e_b),
    .alu_select(e_alu_select),
    .alu_result(alu_result)
  );

  reg [4:0] w_rd_reg = w_rd;
  reg [31:0] w_data_rd_reg;

  always @(*) begin
    if (w_pc == m_pc) begin
      w_rd_reg = 0;
      w_data_rd_reg = 0;
    end else begin
      w_rd_reg = w_rd;
      w_data_rd_reg = w_data_rd;
    end
  end

  register_file register_file1 (
  .clock(clock),
  .addr_rs1(d_rs1),
  .addr_rs2(d_rs2),
  .addr_rd(w_rd_reg),
  .data_rd(w_data_rd_reg),
  .data_rs1(data_rs1),
  .data_rs2(data_rs2),
  .write_enable(w_write_enable),
  .reset(reset)
  );

  reg signed [31:0]  m_data_out;

  dmemory dmem_1 (
    .clock(clock),
    .access_size(m_access_size_controller),
    .m_address(m_alu_result),
    .m_data_in(w_data_rs2),
    .m_rw(m_dmem_rw),
    .is_signed(m_is_signed_controller),
    .m_data_out(m_data_out)
  );

  write_back write_back1 (
    .alu(w_alu_result),
    .mem(w_data_out),
    .pc(w_pc + 4),
    .data_select(w_wb_select),
    .wb_out(w_data_rd),
    .is_stalled(w_stall)
  );

  reg [31:0] d_pc;
  reg [31:0] e_pc;
  reg [31:0] m_pc;
  reg [31:0] w_pc;
  reg [31:0] d_instruction;
  reg [31:0] e_instruction;
  reg signed [31:0] e_data_rs1;
  reg signed [31:0] e_data_rs2;
  reg signed [31:0] m_data_rs2;
  reg [4:0] e_rs1;
  reg [4:0] e_rs2;
  reg [4:0] m_rs2;
  reg [4:0] e_rd;
  reg [4:0] m_rd;
  reg [4:0] w_rd;
  reg [31:0] e_imm;
  reg [4:0] e_shamt;
  reg [2:0] e_funct3;
  reg [6:0] e_funct7;
  reg [6:0] e_opcode;
  reg [6:0] m_opcode;
  reg [6:0] w_opcode;
  reg e_write_enable;
  reg m_write_enable;
  reg w_write_enable;
  reg w_write_enable_prev;
  reg m_is_signed_controller;
  reg [1:0] m_access_size_controller;
  reg m_dmem_rw;
  reg [1:0] m_wb_select;
  reg [1:0] w_wb_select;
  reg signed [31:0] e_a;
  reg signed [31:0] e_b;
  reg [3:0] e_alu_select;
  reg signed [31:0] m_alu_result;
  reg signed [31:0] w_alu_result;
  reg signed [31:0] w_data_out;

  reg mx_rs1_flag;
  reg mx_rs2_flag;
  reg signed [31:0] mx_data_forwarded;

  reg wx_rs1_flag;
  reg wx_rs2_flag;
  reg signed [31:0] wx_data_forwarded;

  // reg wm_rd_flag;
  reg signed [31:0] w_data_rs2;


  reg [31:0] temp_e_rs1 = 0;
  reg [31:0] temp_e_rs2 = 0;
  always @(*) begin
    // forwarding MX for stores 
    temp_e_rs1[4:0] = e_rs1;
    temp_e_rs2[4:0] = e_rs2;

    if ((m_opcode == 7'b0000011) || (m_opcode == 7'b0100011)) begin
      mx_data_forwarded = m_data_rs2;
      if ((temp_e_rs1 == m_alu_result) && (e_rs1 != 0)) begin
        mx_rs1_flag = 1;
      end else begin
        mx_rs1_flag = 0;
      end

      if ((temp_e_rs2 == m_alu_result) && (e_rs2 != 0)) begin
        mx_rs2_flag = 1;
      end else begin
        mx_rs2_flag = 0;
      end

    end else begin
      mx_data_forwarded = m_alu_result;
      if ((e_rs1 == m_rd) && (m_rd != 0) && (m_opcode!=7'b1100011)) begin
        mx_rs1_flag = 1;
      end else begin
        mx_rs1_flag = 0;
      end

      if ((e_rs2 == m_rd) && (m_rd != 0) && (m_opcode!=7'b1100011)) begin
        mx_rs2_flag = 1;
      end else begin
        mx_rs2_flag = 0;
      end
    end

    // forwarding WX for writes to registers that are read in the next cycle's alu
    wx_data_forwarded = w_data_rd;
    if ((e_rs1 == w_rd) && (w_rd != 0)  && (w_opcode!=7'b1100011) && (w_opcode!=7'b0100011)) begin
      wx_rs1_flag = 1;
    end else begin
      wx_rs1_flag = 0;
    end
    
    if ((e_rs2 == w_rd) && (w_rd != 0) && (w_opcode!=7'b1100011) && (w_opcode!=7'b0100011)) begin
      wx_rs2_flag = 1;
    end else begin
      wx_rs2_flag = 0;
    end

    // forwarding WM for stores to registers that are also being written to in the next cycle
    if ((w_rd == m_rs2) && (w_rd!= 0) && (w_write_enable) && ((m_opcode==7'b1100011) || (m_opcode==7'b0100011) || (m_opcode==7'b0110011))) begin
      w_data_rs2 = w_data_rd;
    end 
    else if ((w_rd_prev == m_rs2) && (w_rd_prev!= 0) && (w_write_enable_prev) && ((m_opcode==7'b1100011) || (m_opcode==7'b0100011) || (m_opcode==7'b0110011))) begin
      w_data_rs2 = w_data_rd_prev;
    end else begin
      w_data_rs2 = m_data_rs2;
    end
  end

  reg m_branch_taken;
  reg w_branch_taken;

  reg e_stall;
  reg m_stall;
  reg w_stall;


  always @(posedge clock) begin
    m_branch_taken <= branch_taken;
    w_branch_taken <= m_branch_taken;
    
    e_stall <= stall;
    m_stall <= e_stall;
    w_stall <= m_stall;
    if (reset) begin
      d_pc <= 0;
      e_pc <= 0;
      m_pc <= 0;
      w_pc <= 0;
      d_instruction <= 0;
      e_instruction <= 0;
      e_data_rs1 <= 0;
      e_data_rs2 <= 0;
      m_data_rs2 <= 0;
      e_rs1 <= 0;
      e_rs2 <= 0;
      m_rs2 <= 0;
      e_rd <= 0;
      m_rd <= 0;
      w_rd <= 0;
      e_imm <= 0;
      e_shamt <= 0;
      e_funct3 <= 0;
      e_funct7 <= 0;
      e_opcode <= 0;
      m_opcode <= 0;
      w_opcode <= 0;
      m_write_enable <= 0;  
      w_write_enable <= 0;
      w_write_enable_prev <= 0;
      m_is_signed_controller <= 0;
      m_access_size_controller <= 0;
      m_dmem_rw <= 0;
      m_wb_select <= 0;
      w_wb_select <= 0;
      m_alu_result <= 0;
      w_alu_result <= 0;
      w_data_out <= 0;
    end 
    else if (!stall & !jump & !branch_taken) begin

      d_pc <= pc;
      e_pc <= d_pc;
      m_pc <= e_pc;
      w_pc <= m_pc;

      d_instruction <= instruction;
      e_instruction <= d_instruction;


      e_data_rs1 <= data_rs1;
      e_data_rs2 <= data_rs2;
      m_data_rs2 <= e_data_rs2;
      
      e_rs1 <= d_rs1;
      e_rs2 <= d_rs2;
      m_rs2 <= e_rs2;
      e_rd <= d_rd;
      m_rd <= e_rd;
      if (!m_stall) begin
        w_rd <= m_rd;
      end else begin
        w_rd <= 0;
        w_data_out <= 0;
      end

      // if (w_pc == m_pc) begin
      //   w_rd <= m_rd;
      // end
      w_rd_prev <= w_rd_reg;
      w_data_rd_prev <= w_data_rd;

      e_imm <= d_imm;
      e_shamt <= d_shamt;
      e_funct3 <= d_funct3;
      e_funct7 <= d_funct7;
      e_opcode <= d_opcode;
      m_opcode <= e_opcode;
      w_opcode <= m_opcode;

      m_write_enable <= write_enable;
      w_write_enable <= m_write_enable;
      w_write_enable_prev <= w_write_enable;

      m_is_signed_controller <= is_signed_controller;
      m_access_size_controller <= access_size_controller;
      m_dmem_rw <= dmem_rw;
      m_wb_select <= wb_select;
      w_wb_select <= m_wb_select;
      
      m_alu_result <= alu_result;
      w_alu_result <= m_alu_result;
      w_data_out <= m_data_out;
    end 
    else if (branch_taken || jump) begin
      e_pc <= d_pc;
      m_pc <= e_pc;
      w_pc <= m_pc;
      
      d_instruction <= 32'h00000013;
      // d_instruction[11:7] <= 0;
      e_instruction <= 0;


      e_data_rs1 <= 0;
      m_data_rs2 <= e_data_rs2;
      
      e_rs1 <= 0;
      m_rs2 <= e_rs2;
      e_rd <= 0;
      m_rd <= e_rd;
      w_rd <= m_rd;
      w_rd_prev <= w_rd_reg;
      w_data_rd_prev <= w_data_rd;

      e_imm <= 0;
      e_opcode <= 7'b0010011;
      m_opcode <= e_opcode;
      w_opcode <= m_opcode;
      e_funct3 <= 0;

      m_write_enable <= write_enable;
      w_write_enable <= m_write_enable;
      w_write_enable_prev <= w_write_enable;


      m_is_signed_controller <= is_signed_controller;
      m_access_size_controller <= access_size_controller;
      m_dmem_rw <= dmem_rw;
      m_wb_select <= wb_select;
      w_wb_select <= m_wb_select;

      m_alu_result <= alu_result;
      w_alu_result <= m_alu_result;
      w_data_out <= m_data_out;
    end else begin
      // stall = 1;
      e_pc <= d_pc;
      m_pc <= e_pc;
      w_pc <= m_pc;

      // d_instruction <= 32'h00000013
      // if (d_opcode != 7'b0100011 && d_opcode != 7'b1100011) begin
      //   d_instruction[11:7] <= 0;
      // end 
      if (d_opcode != 7'b0100011 && d_opcode != 7'b1100011 && d_opcode != 7'b0110011 && d_opcode != 7'b0010011 && d_opcode != 7'b0000011 && d_opcode != 7'b1100111  && d_opcode != 7'b1101111) begin
        d_instruction[11:7] <= 0;
      end 
      // e_instruction <= d_instruction;

      e_instruction <= 0;

      e_data_rs1 <= 0;
      m_data_rs2 <= e_data_rs2;
      
      e_rs1 <= 0;
      m_rs2 <= e_rs2;
      e_rd <= 0;
      m_rd <= e_rd;
      w_rd <= m_rd;
      w_rd_prev <= w_rd_reg;
      w_data_rd_prev <= w_data_rd;

      e_imm <= 0;
      e_opcode <= 7'b0010011;
      m_opcode <= e_opcode;
      w_opcode <= m_opcode;
      e_funct3 <= 0;
      e_rd <= 0;

      m_write_enable <= write_enable;
      w_write_enable <= m_write_enable;
      w_write_enable_prev <= w_write_enable;

      m_is_signed_controller <= is_signed_controller;
      m_access_size_controller <= access_size_controller;
      m_dmem_rw <= dmem_rw;
      m_wb_select <= wb_select;
      w_wb_select <= m_wb_select;

      m_alu_result <= alu_result;
      w_alu_result <= m_alu_result;
      w_data_out <= m_data_out;
    end
  end

endmodule