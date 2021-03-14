module StmMux_c(
  input logic rs2_i,
  input logic rd_i,
  input logic sel,
  output logic rs2_o
);

  assign rs2_o = ~sel ? rs2_i : rd_i;

endmodule