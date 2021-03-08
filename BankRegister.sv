module BankRegister(
  input logic
  clk,
  cen,//clk enable
  rst,
  we,
  input logic [2:0]
  rs_i,
  rs2_i,
  rd_i,
  input logic [7:0]
  dat_i,
  output logic [7:0]
  rs_o,
  rs2_o,
  rd_o
);

  integer i;
  logic [7:0]mem [7:0];//array of ff
  logic clkg;

  always_comb clkg = clk & cen;

  always_ff @(posedge clkg or posedge rst) begin
    if(rst)
      for(i = 0; i <= 7; i = i+1) mem[i] <= 0;
    else if(we)
      mem[rd_i] <= dat_i;
  end

  always_comb begin
    rs_o = mem[rs_i];
    rs2_o = mem[rs2_i];
  end

endmodule
