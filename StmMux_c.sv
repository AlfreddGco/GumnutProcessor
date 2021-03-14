module StmMux_c(
  input logic [2:0] rs2_i,
  input logic [2:0] rd_i,
  input logic sel,
  output logic [2:0] rs2_o
);

  assign rs2_o = ~sel ? rs2_i : rd_i;

endmodule