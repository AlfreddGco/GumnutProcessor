module NewPC(
  input logic
  carry_i,
  zero_i,
  input logic [3:0]
  PCoper_i,//selector
  input logic [7:0]
  disp_i,//branch offset
  input logic [11:0]
  addr_i,//jmp addr
  PC_i,//current PC
  output logic [11:0]
  PC_o
);

  logic [11:0] branch;
  logic [1:0] decoded_operation;

  always_comb begin

  end

  always_comb begin 
    case(decoded_operation) 
      2'b00: PC_o = (PC_i+1);
      2'b01: PC_o = addr_i; //jump
      2'b10: PC_o = (PC_i + disp_i);
      2'b11: PC_o = (PC_i+1);
    endcase 
  end

endmodule
