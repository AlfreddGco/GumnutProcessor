`include "./IR.sv"
`include "./Mux4to1.sv"
`include "./Mux2to1.sv"
`include "./StmMux_c.sv"
`include "./BankRegister.sv"
`include "./FlagReg.sv"
`include "./ALU.sv"

module punit(
  input logic clk_i,
  input logic ClkEn_i,
  input logic rst_i,
  input logic [17:0] inst_dat_i,
  input logic inst_ack_i,
  input logic [7:0] data_dat_i,
  input logic [7:0] port_data_i,
  input logic [1:0] RegMux_c_i,
  input logic RegWrt_c_i,
  input logic op2_c_i,
  input logic [3:0] ALUOp_c_i,
  //
  input logic stm_mux_i,
  input logic ALUFR_c_i,
  input logic ALUEn_c_i,
  input logic reti_c_i,
  input logic intc_i,
  input logic intz_i,
  input logic ccC_e_i,//alus carry
  //
  output logic [6:0] op_o,
  output logic [2:0] func_o,
  output logic [11:0] addr_o,
  output logic [7:0] disp_o,
  output logic [7:0] res_o,
  //
  output logic ccC_e_o,
  output logic ccZ_e_o
);

//IR wires
wire [2:0] rs_e, rs2_e, rd_e, count_e, rs2_br_e;
wire [7:0] immed_e;

IR instruction_register(
  .ack_i(inst_ack_i),
  .inst_i(inst_dat_i),
  .func_o(func_o),
  .rs_o(rs_e),//internal module's wire
  .rs2_o(rs2_e),//int
  .rd_o(rd_e),//int
  .count_o(count_e),//int
  .op_o(op_o),//int
  .disp_o(disp_o),//int
  .immed_o(immed_e),//int
  .addr_o(addr_o)
);

StmMux_c stm_mux(
  .rs2_i(rs2_e),
  .rd_i(rd_e),
  .sel(stm_mux_i),
  .rs2_o(rs2_br_e)
);

wire [7:0] ALU_e, dat_e;

Mux4to1 mux4(
  .A_i(ALUEn_c_i ? ALU_e : 8'b0),
  .B_i(data_dat_i),
  .C_i(port_data_i),
  .Sel(RegMux_c_i),
  .M(dat_e)
);

FlagReg flag_reg(
  .clk(clk_i),
  .cen(ClkEn_i),
  .rst(rst_i),
  .we(ALUFR_c_i),
  .iwe(reti_c_i),
  .c_i(carry_e),
  .z_i(zero_e),
  .intc_i(intc_i),
  .intz_i(intz_i),
  .c_o(ccC_e_o),
  .z_o(ccZ_e_o)
);


wire [7:0] rsr_e, rsr2_e;

BankRegister bank_register(
  .clk(clk_i),
  .cen(ClkEn_i),//clk enable
  .rst(rst_i),
  .we(RegWrt_c_i),
  .rs_i(rs_e),
  .rs2_i(rs2_br_e),
  .rd_i(rd_e),
  .dat_i(dat_e),
  .rs_o(rsr_e),
  .rs2_o(rsr2_e)
);

wire [7:0] op2_e;

Mux2to1 mux2(
  .ina(rsr2_e),
  .inb(immed_e),
  .sel(op2_c_i),
  .m(op2_e)
);

wire carry_e, zero_e;

ALU alu(
  .rs_i(rsr_e),
  .op2_i(op2_e),
  .count_i(count_e),
  .carry_i(ccC_e_i),
  .ALUOp_i(ALUOp_c_i),
  .zero_o(zero_e),
  .carry_o(carry_e),
  .res_o(ALU_e)
);

assign res_o = ALU_e;

endmodule