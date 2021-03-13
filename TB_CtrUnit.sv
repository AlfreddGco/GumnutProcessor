`timescale 1ns / 1ns
`include "CtrlUnit.sv"

module TB_CtrlUnit();

  logic clk = '0;
  logic [6:0] op_i = '0;

  CtrlUnit c1(
    .clk(clk),
    .op_i(op_i)
  );

  logic [6:0] operations_array[1:0];

  always #5 clk <= ~clk;

  initial begin
    $dumpfile("ctrlUnit.vcd");
    $dumpvars(0, TB_CtrlUnit);

    operations_array[0] = 7'b110;
    operations_array[1] = 7'b10;
    
    #10
    $display("Number of operations: %d", $size(operations_array));
    for(int i = 0; i < $size(operations_array); i++) begin
      op_i = operations_array[i];
      #10;
    end
    $finish();
  end

endmodule