module NewPC(
  input logic [3:0] PCoper_i,//selector
  input logic carry_i,
  input logic zero_o,
  input logic [11:0] stackaddr_i,
  input logic [11:0] intPC_i,//stack address
  input logic [11:0] PC_i,//current PC
  input logic [7:0] offset_i,//branch offset
  input logic [11:0] addr_i,//jmp addr
  output logic [11:0] PC_o
);

  always_comb begin 
    case(PCoper_i)
      4'b0000: PC_o = (PC_i+1);
      4'b0100: PC_o = (zero_i) ? (PC_i + offset_i) :  (PC_i + 1); //branch
      4'b0101: PC_o = (!zero_i) ? (PC_i + offset_i) :  (PC_i + 1); //branch
      4'b0110: PC_o = (carry_i) ? (PC_i + offset_i) : (PC_i + 1); //branch
      4'b0111: PC_o = (!carry_i) ? (PC_i + offset_i) : (PC_i + 1); //branch
      4'b1000: PC_o = addr_i;//jump
      4'b1100: PC_o = intP;//from intReg
      4'b1010: PC_o = stackaddr_i;//stack subroutine
    endcase 
  end

endmodule
