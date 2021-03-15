module Mux2to1(
  input logic [7:0]
  ina,
  inb,
  input logic
  sel,
  output logic [7:0]
  m
);

  always_comb begin
    m = (sel === 1'b0) ? ina :
    (sel === 1'b1) ? inb : 8'bx;
  end

endmodule
