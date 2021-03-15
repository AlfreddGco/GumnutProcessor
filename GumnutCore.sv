`include "./CtrlUnit.sv"
`include "./pcunit.sv"
`include "./punit.sv"

module GumnutCore(
  input logic clk_i,
  input logic clkEn_i,
  input logic rst_i,
  //
  input logic int_req_i,
  input logic inst_ack_i,
  output logic [11:0] inst_addr_o,
  input logic [17:0] inst_dat_i,
  input logic [7:0] data_dat_i,
  input logic [7:0] port_dat_i,
  output logic [7:0] port_data_o,
  output logic [7:0] dat_o,
  output logic [7:0] addr_o,
  output logic we_o,
  output logic stb_o,
  output logic cyc_o,
  input logic data_ack_i,
  output logic int_ack_o
);

  wire op2_c, ALUFR_c, ALUEn_c, RegWrt_c;
  wire PCEn_c, pop_c, push_c, StmMux_c, reti_c;
  wire int_c, inst_stb_c, inst_cyc_c, port_we_c;
  wire data_we_c, data_stb_c, data_cyc_c;
  wire ccC_e, ccZ_e;
  wire intc_e, intz_e;
  wire [1:0] RegMux_c;
  wire [2:0] func_e;
  wire [3:0] ALUOp_c, PCoper_c;
  wire [6:0] op_e;
  wire [7:0] disp_e;
  wire [11:0] addr_e;

  CtrlUnit control_unit(
    .clk(clk_i),
    .int_req(int_req_i),
    .inst_ack_i(inst_ack_i),
    .port_ack_i(),
    .op_i(op_e),
    .func_i(func_e),
    .op2_o(op2_c),
    .ALUOp_o(ALUOp_c),
    .ALUFR_o(ALUFR_c),
    .ALUEn_o(ALUEn_c),
    .RegWrt_o(RegWrt_c),
    .RegMux_o(RegMux_c),
    .PCEn_o(PCEn_c),
    .PCoper_o(PCoper_c),
    .ret_o(pop_c),
    .jsb_o(push_c),
    .StmMux_o(StmMux_c),
    .reti_o(reti_c),
    .int_o(int_c),
    .stb_o(inst_stb_c),
    .cyc(inst_cyc_c),
    .port_we_o(port_we_c),
    .data_we_o(data_we_c),
    .data_stb_o(data_stb_c),
    .data_cyc_o(data_cyc_c),
    .data_ack_i(data_ack_i)
  );


  pcunit pc_unit(
    .clk_i(clk_i),
    .ClkEn_i(clkEn_i),
    .rst_i(rst_i),
    //
    .PCoper_c_i(PCoper_c),
    .addr_e_i(addr_e),
    .disp_e_i(disp_e),
    .int_c_i(int_c),
    .PCEn_c_i(PCEn_c),
    .ccC_e_i(ccC_e),
    .ccZ_e_i(ccZ_e),
    .inst_addr_o(inst_addr_o),
    .intc_o(intc_e),
    .intz_o(intz_e)
  );

  punit processing_unit(
    .clk_i(clk_i),
    .ClkEn_i(clkEn_i),
    .rst_i(rst_i),
    .inst_dat_i(inst_dat_i),
    .inst_ack_i(inst_ack_i),
    .data_dat_i(data_dat_i),
    .port_data_i(port_dat_i),
    .RegMux_c_i(RegMux_c),
    .RegWrt_c_i(RegWrt_c),
    .op2_c_i(op2_c),
    .ALUOp_c_i(ALUOp_c),
    //
    .stm_mux_i(StmMux_c),
    .ALUFR_c_i(ALUFR_c),
    .ALUEn_c_i(ALUEn_c),
    .reti_c_i(reti_c),
    .intc_i(intc_e),
    .intz_i(intz_e),
    .ccC_e_i(ccC_e),//alus carry
    //
    .op_o(op_e),
    .func_o(func_e),
    .addr_o(addr_e),
    .disp_o(disp_e),
    .res_o(addr_o),
    //
    .ccC_e_o(ccC_e),
    .ccZ_e_o(ccZ_e)
  );

endmodule