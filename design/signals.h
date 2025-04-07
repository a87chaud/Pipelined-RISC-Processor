
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                pc
`define F_INSN              instruction

`define D_PC                d_pc
`define D_OPCODE            d_opcode
`define D_RD                d_rd
`define D_RS1               d_rs1
`define D_RS2               d_rs2
`define D_FUNCT3            d_funct3
`define D_FUNCT7            d_funct7
`define D_IMM               d_imm
`define D_SHAMT             d_shamt

`define R_WRITE_ENABLE      write_enable
`define R_WRITE_DESTINATION w_rd
`define R_WRITE_DATA        w_data_rd
`define R_READ_RS1          d_rs1
`define R_READ_RS2          d_rs2
`define R_READ_RS1_DATA     data_rs1
`define R_READ_RS2_DATA     data_rs2

`define E_PC                e_pc
`define E_ALU_RES           alu_result
`define E_BR_TAKEN          branch_taken

`define M_PC                m_pc
`define M_ADDRESS           m_alu_result
`define M_RW                m_dmem_rw
`define M_SIZE_ENCODED      m_access_size_controller
`define M_DATA              w_data_rs2

`define W_PC                w_pc
`define W_ENABLE            w_write_enable
`define W_DESTINATION       w_rd
`define W_DATA              w_data_rd_reg

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
