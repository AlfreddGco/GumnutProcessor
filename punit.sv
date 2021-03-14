`include "./IR.sv"
`include "./Mux4to1.sv"
`include "./Mux2to1.sv"
`include "./StmMux_c.sv"
`include "./BankRegister.sv"
`include "./ALU.sv"

module ProcessingUnit(
  input logic clk_i,
  input logic ClkEn_i,
  input logic rst_i,
  input logic [17:0] inst_dat_i,
  input logic inst_ack_i,
  input logic [7:0] data_dat_i,
  input logic [7:0] port_data_i,
  input logic [1:0] RegMux_c_i,
  input logic RegWrt_c_i,
  input logic [1:0] op2_c_i,
  input logic [3:0] ALUOp_c_i,
  //
  input logic stm_mux_i,
  //
  output logic [6:0] op_o,
  output logic [2:0] func_o,
  output logic [11:0] addr_o,
  output logic [7:0] disp_o,
  output logic [7:0] res_o,
  output logic carry_o,
  output logic zero_o
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
  .A_i(ALU_e),
  .B_i(data_dat_i),
  .C_i(port_data_i),
  .Sel(RegMux_c_i),
  .M(dat_e)
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

ALU alu(
  .rs_i(rsr_e),
  .op2_i(op2_e),
  .count_i(),
  .carry_i(),
  .ALUOp_i(ALUOp_c_i),
  .zero_o(zero_o),
  .carry_o(carry_o),
  .res_o(ALU_e)
);

assign res_o = ALU_e;

endmodule