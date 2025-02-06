
module MuxRGB(A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15,SEL,OUT);		//MUX DE 16 A 1
input A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15; //BITS DE FILA
input [3:0]SEL;		//COLUMNA
output reg OUT;	//BIT DE SALIDA

always @(A0 or A1 or A2 or A3 or A4 or A5 or A6 or A7 or A8 or A9 or A10 or A11 or A12 or A13 or A14 or A15 or SEL)
		case (SEL)
			4'd0: OUT= A0;				//Bit 0 de Fila
			4'd1: OUT= A1;				//Bit 1 de Fila
			4'd2: OUT= A2;				//Bit 2 de Fila
			4'd3: OUT= A3;				//Bit 3 de Fila
			4'd4: OUT= A4;				//Bit 4 de Fila
			4'd5: OUT= A5;				//Bit 5 de Fila
			4'd6: OUT= A6;				//Bit 6 de Fila
			4'd7: OUT= A7;				//Bit 7 de Fila
			4'd8: OUT= A8;				//Bit 8 de Fila
			4'd9: OUT= A9;				//Bit 9 de Fila
			4'd10: OUT= A10;			//Bit 10 de Fila
			4'd11: OUT= A11;			//Bit 11 de Fila
			4'd12: OUT= A12;			//Bit 12 de Fila
			4'd13: OUT= A13;			//Bit 13 de Fila
			4'd14: OUT= A14;			//Bit 14 de Fila
			4'd15: OUT= A15;			//Bit 15 de Fila
		endcase
endmodule
