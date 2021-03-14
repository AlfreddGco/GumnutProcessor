module IntReg(
  output logic [11:0] pc_o,
  input logic c_i,
  input logic z_i,
  input logic clk,
  input logic cen,
  input logic rst,
  input logic we,
  output logic intc_o,
  output logic intz_o,
  input logic [11:0] pc_i
);

  logic gClk = clk & cen;

  always_ff @(posedge gClk) begin
    if(rst) begin 
      pc_o <= 12'b0;
      intc_o <= 1'b0;
      intz_o <= 1'b0;
    end
    else if(!rst & we) begin
      pc_o <= pc_i;
      intc_o <= c_i;
      intz_o <= z_i;
    end
  end

endmodule