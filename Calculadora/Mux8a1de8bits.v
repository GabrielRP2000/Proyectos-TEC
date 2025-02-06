`timescale 1ns / 1ps


module Mux8a1de8bits(A,B,C,D,E,F,G,H,OP,OUT);
	input [39:0] A,B,C,D,E,F,G,H;
	input [2:0] OP;
	output reg [39:0] OUT;
	
	always @(OP or A or B or C or D or E or F or G or H)
		case (OP)
			3'b000: OUT=A;
			3'b001: OUT=B;
			3'b010: OUT=C;
			3'b011: OUT=D;
			3'b100: OUT=E;
			3'b101: OUT=F;
			3'b110: OUT=G;
			3'b111: OUT=H;
		endcase

endmodule
