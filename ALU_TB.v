`timescale 1ns / 1ps

module ALU_TB;

	// Inputs
	reg [7:0] A;
	reg [7:0] B;
	reg [2:0] ctrl;

	// Outputs

	wire Ov;
	wire Neg;
	wire Zero;
	wire Cout;
	wire [7:0] S;

	integer i;
	integer j;
	integer k;
	integer ErrCnt = 0;

	// Instantiate the Device Under Test (DUT)
	ALU alu_dut (
		.A(A),
		.B(B),
		.x(ctrl[2]),
		.y(ctrl[1]),
		.z(ctrl[0]),
		.Cout(Cout),
		.S(S),
		.Ov(Ov),
		.Neg(Neg),
		.Zero(Zero)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		ctrl = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
	    for (k = 0 ; k < 8 ; k = k + 1) begin	
	    	for (i = 0 ; i < 256 ; i = i + 1) begin
		     for (j = 0 ; j < 256 ; j = j + 1) begin
				A 	= i;
				B 	= j;
				ctrl	= k;
				#10;
		     end
		end
	     end
	if(ErrCnt !=0) $display("Test Failed: Encountered %d errors please debug", ErrCnt);
	else $display("Test Successfull: Encountered %d errors, Congrats!", ErrCnt);

	end

	reg [7:0] S_Ref;
	reg       Ov_Ref, Co_Ref, Neg_Ref, Zero_Ref, Borrow;

   // KEEP in mind following Coding Style is for the Testbench Only which is SOFTWARE based coding style -
   // This would likely not synthesize to valid HARDWARE.

	always @ (A,B,ctrl) begin : checker
		reg error;
		Borrow =0;
		//#1;
		case (ctrl)
			3'b000: {Co_Ref,S_Ref} =  A+B;
			3'b001: {Borrow,S_Ref} =  A-B;
			3'b010: {Co_Ref,S_Ref} =  A+1;
			3'b011: {Co_Ref,S_Ref} =  {1'b0,A};
			3'b100: S_Ref =  A&B;
			3'b101: S_Ref =  A|B;
			3'b110: S_Ref =  A^B;
			3'b111: S_Ref =  ~A;
		endcase

		//Overflow Flag logic Addition
		if (ctrl == 3'b000) // Arithmetic Operation  (A+B)
			if( (A[7] == B[7]) )   
				if (S_Ref[7] == A[7]  && S_Ref[7] == B[7])
					Ov_Ref = 1'b0;
					else
						Ov_Ref = 1'b1;
			else
				Ov_Ref = 1'b0;
		//Overflow Flag Logic Substraction
		if (ctrl == 3'b001)  // Arithmetic Operation (A-B) same logic as above though -- +
			if( (A[7] == ~B[7]) )   
				if (S_Ref[7] == A[7]  && S_Ref[7] == ~B[7])
					Ov_Ref = 1'b0;
					else
						Ov_Ref = 1'b1;
			else
				Ov_Ref = 1'b0;

		//Overflow Flag Logic A+1	// Only possible Overflow condition is A = 0111_1111 + 1
		if (ctrl == 3'b010)
			if (A == 8'd127) Ov_Ref = 1'b1;
				else Ov_Ref = 1'b0;
	
		// Reference SW model on a Substract the Co is a Borrow ; need to invert to match our Adder based HW
		if (ctrl == 3'b001) 
			Co_Ref = ~Borrow;

		if (ctrl[2] == 1'b1 || ctrl == 3'b011) // logical operation & A transparent
			{Ov_Ref, Co_Ref} = 2'b00;  //Zero all Arith only flags
		
		Zero_Ref = (S_Ref == 0);
		Neg_Ref  =  S_Ref[7];

		#1;
		
		error = ((S_Ref != S) || (Ov_Ref != Ov) || (Co_Ref != Cout) || (Neg_Ref != Neg) || (Zero_Ref != Zero) );
/*		Y_G = ~((1'b1&EN)<<A);
		$display("Y_REF = %d",Y_G);
		$display("Y_UUT = %d",Y);
		error = (Y_G != Y);
		if(error) $display("ERROR expected: %b, found: %b", Y_G, Y);
		$display("************");			
*/

		if(error) begin 
			$display("ERROR in operation: CTRL = %b, A: %d, B: %d", ctrl, A,B);
			$display("ERROR expected: SUM = %d, OV: %b, CO: %b, NEG: %b, Z: %b  found: SUM = %d, OV: %b, CO: %b, NEG: %b, Z: %b", S_Ref,Ov_Ref,Co_Ref,Neg_Ref,Zero_Ref,S,Ov,Cout,Neg,Zero);
		ErrCnt = ErrCnt + 1;
		end
	end : checker

endmodule
