module ProgCounter(
  input logic [11:0] PC_i,//address
  input logic we,
  input logic clk,
  input logic cen,
  input logic rst,
  output logic [11:0] PC_o//address
);

  logic gclk = clk & cen;

  always_ff @(posedge gclk) begin
    if(rst) PC_o <= 12'b0;
    else if(!rst & we) PC_o <= PC_i;
  end

endmodule