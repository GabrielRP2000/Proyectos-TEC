`timescale 1ns / 1ps

module Posicionador(PosHor,PosVer,Pos);

input [2:0]PosVer;					//INPUTS DE POS HOR Y VER
input [2:0]PosHor;			
output reg[4:0]Pos;					//OUTPUT DE POSICION EN 5BITS

always@(PosVer or PosHor)			//DECODIFICA CADA ENTRADA PARA DAR LA SALIDA EN 5BITS
	case({PosVer,PosHor})
		6'b000000: Pos = 5'd0;		// +
		6'b000001: Pos = 5'd1;		// -
		6'b000010: Pos = 5'd2;		// X
		6'b000011: Pos = 5'd3;		// /
		6'b000100: Pos = 5'd4;		// =
			
		6'b001000: Pos = 5'd5;		//C
		6'b001001: Pos = 5'd6;		//D
		6'b001010: Pos = 5'd7;		//E
		6'b001011: Pos = 5'd8;		//F
		6'b001100: Pos = 5'd9;		//RAIZ
		
		6'b010000: Pos = 5'd10;		//8
		6'b010001: Pos = 5'd11;		//9
		6'b010010: Pos = 5'd12;		//A
		6'b010011: Pos = 5'd13;		//B
		6'b010100: Pos = 5'd14;		//BORRAR
		
		6'b011000: Pos = 5'd15;		//4
		6'b011001: Pos = 5'd16;		//5
		6'b011010: Pos = 5'd17;		//6
		6'b011011: Pos = 5'd18;		//7
		6'b011100: Pos = 5'd19;		//AC
		
		6'b100000: Pos = 5'd20;		//0
		6'b100001: Pos = 5'd21;		//1
		6'b100010: Pos = 5'd22;		//2
		6'b100011: Pos = 5'd23;		//3
		6'b100100: Pos = 5'd24;		//C
		default: Pos = 5'd0;			//DEFAULT +
	endcase
endmodule
