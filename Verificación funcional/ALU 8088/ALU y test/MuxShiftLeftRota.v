`timescale 1ns / 1ps

module MuxShiftLeftRota(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={A[14:0],A[15]};
			4'b0010: R={A[13:0],A[15:14]};
			4'b0011: R={A[12:0],A[15:13]};
			4'b0100: R={A[11:0],A[15:12]};
			4'b0101: R={A[10:0],A[15:11]};
			4'b0110: R={A[9:0],A[15:10]};
			4'b0111: R={A[8:0],A[15:9]};
			4'b1000: R={A[7:0],A[15:8]};
			4'b1001: R={A[6:0],A[15:7]};
			4'b1010: R={A[5:0],A[15:6]};
			4'b1011: R={A[4:0],A[15:5]};
			4'b1100: R={A[3:0],A[15:4]};
			4'b1101: R={A[2:0],A[15:3]};
			4'b1110: R={A[1:0],A[15:2]};
			4'b1111: R={A[0],A[15:1]};
		endcase
		
endmodule 
