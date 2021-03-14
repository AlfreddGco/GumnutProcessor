module FlagReg(
  input logic clk,
  input logic cen,
  input logic rst,
  input logic we,
  input logic iwe,
  input logic c_i,
  input logic z_i,
  input logic intc_i,
  input logic intz_i,
  output logic c_o,
  output logic z_o
);

logic gClk = clk & cen;

always_ff @(posedge gClk) begin
  if(we) begin
    c_o <= c_i;
    z_o <= z_i;
  end
  else if(iwe) begin
    c_o <= intc_i;
    z_o <= intz_i;
  end
  else if(rst) begin
    c_o = 1'b0;
    z_o = 1'b0;
  end
end

endmodule