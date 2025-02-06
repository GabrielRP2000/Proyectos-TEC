`timescale 1ns / 1ps

module Mux4a1de4bits(A0,A1,A2,A3,SEL,OUT);
	input [3:0] A0,A1,A2,A3;
	input [1:0] SEL;
	output reg [3:0] OUT;
	
	always @(A0 or A1 or A2 or A3 or SEL)
		case (SEL)
			2'b00: OUT=A0;
			2'b01: OUT=A1;
			2'b10: OUT=A2;
			2'b11: OUT=A3;
		endcase

endmodule

