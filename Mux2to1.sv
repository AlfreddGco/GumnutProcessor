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
    m = (sel === 2'b00) ? ina :
    (sel === 2'b01) ? inb : 8'bx;
  end

endmodule
