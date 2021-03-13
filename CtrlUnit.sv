module CtrlUnit(
  input logic clk,
  input logic inst_ack_i,
  input logic data_ack_i,
  input logic port_ack_i,
  input logic [6:0] op_i,//opcode comes from IR
  input logic [2:0] func_i,//subfunction comes from IR
  output logic op2_o,
  output logic [3:0] ALUOp_o,
  output logic RegWrt_o,//write enable bank register
  output logic [1:0] RegMux_o,
  output logic [3:0] PCoper_o,
  output logic [1:0] pop_o,
  output logic int_o,
  output logic stb_o,
  output logic cyc,
  output logic weport_o,
  output logic data_we_o,
  output logic data_stb_o,
  output logic data_cyc_o
);

  //derive this variables from input
  logic shift, mem, branch, jump, misc;
  assign shift = (op_i === 7'b110);
  assign mem = (op_i === 7'b10);
  assign branch = (op_i === 7'b0111110);
  assign jump = (op_i === 7'b0011110);
  assign misc = (op_i === 7'b1111110);

  logic alu_reg;//address (?)
  logic [7:0] alu_immed;
  

  logic stm, ldm;//load memory, store memory
  assign stm = (op_i === 7'b10 & func_i === 3'b00);
  assign ldm = (op_i === 7'b10 & func_i === 3'b01);
  logic inp, out;//input output into register
  assign inp = (op_i === 7'b10 & func_i === 3'b10);
  assign out = (op_i === 7'b10 & func_i === 3'b11);

  logic inter;
  
  logic _wait, stby;
  assign _wait = (op_i === 7'b1111110 & func_i === 3'b100);
  assign stby = (op_i === 7'b1111110 & func_i === 3'b101);


  typedef enum logic [2:0] {
    fetch_state,
    decode_state,
    execute_state,
    mem_state,
    write_back_state,
    int_state
  } State;

  State currentState = fetch_state;
  State nextState;

  always_ff @(posedge clk) begin
    currentState <= nextState;
  end

  //depending on current state we calculate
  //certain logic
  always_comb begin : fetchBlock
    if(currentState == fetch_state) begin
      nextState = (inst_ack_i === 1'b1) ? decode_state : fetch_state;
    end
  end

  always_comb begin : decodeBlock
    if(currentState == decode_state) begin
      if(branch & !inter) nextState = fetch_state;
      else if(jump & !inter) nextState = fetch_state;
      else if(misc & !(_wait | stby) & !inter) nextState = fetch_state;
      else if(misc & (_wait | stby) & !inter) nextState = decode_state;
      else if(alu_immed | alu_reg | shift | mem) nextState = execute_state;
      else nextState = int_state;
    end
  end

  always_comb begin : executeBlock
    if(currentState == execute_state) begin
      if(mem & (ldm | stm) & !data_ack_i) nextState = mem_state;
      else if(mem & (inp | out) & !port_ack_i) nextState = mem_state;
      else if(mem & ldm & data_ack_i) nextState = write_back_state;
      else if(mem & inp & port_ack_i) nextState = write_back_state;
      else if(!mem) nextState = write_back_state;
      else if(mem & stm & data_ack_i & !inter) nextState = fetch_state;
      else if(mem & out & port_ack_i & !inter) nextState = fetch_state;
      else if(mem & stm & data_ack_i & inter) nextState = int_state;
      else if(mem & out & port_ack_i & inter) nextState = int_state;
    end
  end

  always_comb begin : memBlock
    if(currentState == mem_state) begin
      if((ldm | stm) & !data_ack_i) nextState = mem_state;
      else if((inp | out) & !port_ack_i) nextState = mem_state;
      else if(ldm & data_ack_i) nextState = write_back_state;
      else if(inp & port_ack_i) nextState = write_back_state;
      else if(stm & data_ack_i & !inter) nextState = fetch_state;
      else if(out & port_ack_i & !inter) nextState = fetch_state;
      else if(stm & data_ack_i & inter) nextState = int_state;
      else if(out & port_ack_i & inter) nextState = int_state;
    end
  end

  always_comb begin : writeBackBlock
    if(currentState == write_back_state) begin
      nextState = (inter === 1'b1) ? int_state : fetch_state;
    end
  end

  always_comb begin : intBlock
    if(currentState == int_state) begin
      nextState = fetch_state;
    end
  end

  //outputs
  assign int_o = (currentState === int_state);
  assign RegWrt_o = (currentState === write_back_state);
  logic [3:0] aluSelector = 4'b0000;
  assign ALUOp_o = (currentState === decode_state | currentState === write_back_state | currentState === execute_state) ? aluSelector : 4'bxxxx;

endmodule