module IR(
  input logic
  ack_i,
  input logic [17:0]
  inst_i,
  output logic [2:0]
  func_o,//
  rs_o,
  rs2_o,
  rd_o,
  count_o,
  output logic [6:0]
  op_o,
  output logic [7:0]
  disp_o,
  offset_o,//
  immed_o,//
  output logic [11:0]
  addr_o//
);

  //Control Unit
  always_comb op_o = {0, 0, 0, inst_i[17:14]};
  always_comb func_o = inst_i[17] ? inst_i[2:0] : inst_i[16:14];
  //logic
  always_comb rs_o = inst_i[10:8];
  always_comb rs2_o = inst_i[7:5];
  always_comb rd_o = inst_i[13:11];
  always_comb immed_o = inst_i[7:0];
  always_comb count_o = inst_i[7:5];
  //others
  always_comb addr_o = inst_i[11:0];
  always_comb offset_o = inst_i[7:0];
  always_comb disp_o = inst_i[7:0];

endmodule
