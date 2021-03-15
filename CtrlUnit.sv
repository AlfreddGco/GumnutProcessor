module CtrlUnit(
  input logic clk,
  input logic int_req,
  input logic inst_ack_i,
  input logic data_ack_i,
  input logic port_ack_i,
  input logic [6:0] op_i,//opcode comes from IR
  input logic [2:0] func_i,//subfunction comes from IR
  output logic op2_o,//activates immed
  output logic [3:0] ALUOp_o,
  output logic ALUFR_o,
  output logic ALUEn_o,
  output logic RegWrt_o,//write enable bank register
  output logic [1:0] RegMux_o,//selects dat_i for bank register
  output logic PCEn_o,
  output logic [3:0] PCoper_o,
  output logic ret_o,
  output logic jsb_o,
  output logic StmMux_o,
  output logic reti_o,
  output logic int_o,
  output logic stb_o,
  output logic cyc,
  output logic port_we_o,
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

  logic alu_immed, alu_reg; //
  assign alu_immed = (op_i === 7'b0);

  logic stm, ldm;//load memory, store memory
  assign stm = (op_i === 7'b10 & func_i === 3'b00);
  assign ldm = (op_i === 7'b10 & func_i === 3'b01);
  logic inp, out;//input output into register
  assign inp = (op_i === 7'b10 & func_i === 3'b10);
  assign out = (op_i === 7'b10 & func_i === 3'b11);

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
      if(branch & !int_req) nextState = fetch_state;
      else if(jump & !int_req) nextState = fetch_state;
      else if(misc & !(_wait | stby) & !int_req) nextState = fetch_state;
      else if(misc & (_wait | stby) & !int_req) nextState = decode_state;
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
      else if(mem & stm & data_ack_i & !int_req) nextState = fetch_state;
      else if(mem & out & port_ack_i & !int_req) nextState = fetch_state;
      else if(mem & stm & data_ack_i & int_req) nextState = int_state;
      else if(mem & out & port_ack_i & int_req) nextState = int_state;
    end
  end

  always_comb begin : memBlock
    if(currentState == mem_state) begin
      if((ldm | stm) & !data_ack_i) nextState = mem_state;
      else if((inp | out) & !port_ack_i) nextState = mem_state;
      else if(ldm & data_ack_i) nextState = write_back_state;
      else if(inp & port_ack_i) nextState = write_back_state;
      else if(stm & data_ack_i & !int_req) nextState = fetch_state;
      else if(out & port_ack_i & !int_req) nextState = fetch_state;
      else if(stm & data_ack_i & int_req) nextState = int_state;
      else if(out & port_ack_i & int_req) nextState = int_state;
    end
  end

  always_comb begin : writeBackBlock
    if(currentState == write_back_state) begin
      nextState = (int_req === 1'b1) ? int_state : fetch_state;
    end
  end

  always_comb begin : intBlock
    if(currentState == int_state) begin
      nextState = fetch_state;
    end
  end

  //OUTPUTS
  assign op2_o = (op_i === 7'b0);//immed operation

  always_comb begin : aluBlock
    if(!shift & !mem & !branch & !jump) begin
      if(func_i === 3'b000 | func_i === 3'b001) ALUOp_o = 4'b000;//add
      else if(func_i === 3'b010 | func_i === 3'b011) ALUOp_o = 4'b001;//sub
      else if(func_i === 3'b100) ALUOp_o = 4'b010;//and
      else if(func_i === 3'b101) ALUOp_o = 4'b011;//or
      else if(func_i === 3'b110) ALUOp_o = 4'b100;//xor
      else if(func_i === 3'b111) ALUOp_o = 4'b101;//mask
    end
    else ALUOp_o = 4'bxxxx;
  end

  assign ALUFR_o = (currentState === int_state);//alu flags
  assign ALUEn_o = (currentState === execute_state);//alu enable

  assign RegWrt_o = (currentState === write_back_state);

  //00 (ALU) 01 (data_dat) 10 (port_dat) -> bank_register.dat_i
  always_comb begin : RegMuxBlock
    if(mem & (func_i === 3'b00 | func_i === 3'b01)) RegMux_o = 2'b01;
    else if(mem & (func_i === 3'b10 | func_i === 3'b11)) RegMux_o = 2'b10;
    else RegMux_o = 2'b00;
  end

  assign PCEn_o = (currentState === write_back_state);//(?)

  always_comb begin : PCOperBlock
    if(currentState === write_back_state) begin
      if(branch & func_i === 3'b00) PCoper_o = 4'b0100;//z=1
      else if(branch & func_i === 3'b01) PCoper_o = 4'b0101;//z=0
      else if(branch & func_i === 3'b10) PCoper_o = 4'b0110;//c=1
      else if(branch & func_i === 3'b11) PCoper_o = 4'b0111;//c=0
      else if(jump) PCoper_o = 4'b1000;//jump
      //intReg missing
      //stack missing
    end
    else PCoper_o = 4'b0000;//read when memory state
  end

  assign ret_o = 1'b0;//dont care (push stack)
  assign jsb_o = 1'b0;//dont care (pop stack)

  assign StmMux_o = (currentState === fetch_state);

  assign reti_o = (currentState === int_state);
  assign int_o = (currentState === int_state);

  assign stb_o = stby;
  assign cyc = (currentState === fetch_state | currentState === int_state);

  assign port_we_o = (currentState === execute_state);//
  assign data_we_o = (currentState === fetch_state | currentState === mem_state);//
  assign data_stb_o = (currentState === fetch_state | currentState === mem_state);//
  assign data_cyc_o = (currentState === fetch_state | currentState === mem_state);//

endmodule