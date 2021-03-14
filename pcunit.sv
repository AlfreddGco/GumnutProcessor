`include "NewPC.sv"
`include "IntReg.sv"
`include "ProgCounter.sv"

module pcunit(
  input logic clk_i,
  input logic ClkEn_i,
  input logic rst_i,
  //
  input logic [3:0] PCoper_c_i,
  input logic [11:0] addr_e_i,
  input logic [7:0] disp_e_i,
  input logic int_c_i,
  input logic PCEn_c_i,
  input logic ccC_e_i,
  input logic ccZ_e_i,
  output logic [11:0] inst_addr_o,
  output logic intc_o,
  output logic intz_o
);

  wire [11:0] PCnew_e, PC_e, intPC_e;
  assign inst_addr_o = PC_e;

  NewPC new_pc(
    .PCoper_i(PCoper_c_i),
    .carry_i(ccC_e_i),
    .zero_i(ccZ_e_i),
    .stackaddr_i(12'b0),
    .intPC_i(intPC_e),
    .offset_i(disp_e_i),
    .addr_i(addr_e_i),
    .PC_i(PC_e)
  );


  IntReg int_reg(
    .pc_o(intPC_e),
    .c_i(ccC_e_i),
    .z_i(ccZ_e_i),
    .clk(clk_i),
    .cen(ClkEn_i),
    .rst(rst_i),
    .we(int_c_i),
    .intz_o(intz_o),
    .intc_o(intc_o),
    .pc_i(PC_e)
  );

  ProgCounter prog_counter(
    .PC_i(PCnew_e),
    .we(PCEn_c_i),
    .clk(clk_i),
    .cen(clkEn_i),
    .rst(rst_i),
    .PC_o(PC_e)
  );

endmodule