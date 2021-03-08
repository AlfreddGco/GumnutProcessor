module Mux4to1(
  input logic [7:0]
  A_i, B_i, C_i, D_i,
  input logic [1:0] Sel,//this comes from the CU
  output logic [7:0] M
);

  always_comb begin
    M = (Sel === 2'b00) ? A_i :
    (Sel === 2'b01) ? B_i :
    (Sel === 2'b10) ? C_i :
    (Sel === 2'b11) ? D_i : 8'bx;
  end

endmodule
