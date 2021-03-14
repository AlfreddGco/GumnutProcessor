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
  assign op_o = {3'b000, inst_i[17:14]};
  assign func_o = inst_i[17] ? inst_i[2:0] : inst_i[16:14];
  //logic
  assign rs_o = inst_i[10:8];
  assign rs2_o = inst_i[7:5];
  assign rd_o = inst_i[13:11];
  assign immed_o = inst_i[7:0];
  assign count_o = inst_i[7:5];
  //others
  assign addr_o = inst_i[11:0];
  assign offset_o = inst_i[7:0];
  assign disp_o = inst_i[7:0];

endmodule
