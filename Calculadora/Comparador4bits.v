
module Comparador4bits(B,S);			//COMPARA SI EL BIT ES 1 O 0 PARA PINTAR

input  B;
reg [3:0] STEMP;
output [3:0] S;

always@(B)
	if(B==1'b1)
		STEMP = 4'b1110;
	else
		STEMP = 4'b0000;

assign S = STEMP;
endmodule
