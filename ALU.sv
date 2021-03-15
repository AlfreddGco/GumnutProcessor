module ALU(
  input logic
  carry_i,
  input logic [2:0]
  count_i,
  input logic [3:0]
  ALUOp_i,
  input logic [7:0]
  rs_i,
  op2_i,
  output logic
  carry_o,
  zero_o,
  output logic [7:0]
  res_o
);

  always_comb begin
    case(ALUOp_i)
      4'b0000: {carry_o, res_o} = rs_i + op2_i;
      4'b0001: {carry_o, res_o} = rs_i + op2_i + carry_i;
      4'b0010: {carry_o, res_o} = rs_i - op2_i;
      4'b0011: {carry_o, res_o} = rs_i - op2_i - carry_i;
      4'b0100: {carry_o, res_o} = rs_i & op2_i;
      4'b0101: {carry_o, res_o} = rs_i | op2_i;
      4'b0110: {carry_o, res_o} = rs_i ^ op2_i;
      4'b0111: {carry_o, res_o} = rs_i & ~op2_i;
      //shifts and rotations
      4'b1000: {carry_o, res_o} = {1'b0, rs_i} << count_i;//shift left
      4'b1001: {res_o, carry_o} = {rs_i, 1'b0} >> count_i;//shift right
      4'b1010: begin
        res_o = (A << count_i) | (A >> (8 - count_i));//rotate left
        carry_o = S[0];
      end
      4'b1011: begin
        res_o = (A >> count_i) | (A << (8 - count_i));//rotate right
        carry_o = S[7];
      end
      //dont cares
    endcase

    zero_o = (res_o === 8'b0);
  end

endmodule
