
module Compa_Pant_calc(clk,CuentaXa,CuentaYa,numeros,Pos);
	input clk;
	input [39:0] numeros;
	input [5:0] CuentaXalta;		//CUENTA X ALTA DEL SINCRONIZADOR
	input [5:0] CuentaYalta;		//CUENTA Y ALTA DEL SINCRONIZADOR
	output wire [4:0] Pos;
	
	reg [3:0] FontSelect;

	always@(CuentaXa or CuentaYa)
		case({CuentaXa,CuentaYa})

			//////////////////////////////////////////////////////////////////// BLOQUE PANTALLITA
			12'b000010000101: FontSelect = numeros[39:36];		//CARACTER 9 //32
			12'b000110000101: FontSelect = numeros[35:32];		//CARACTER 8 //96
			12'b001010000101: FontSelect = numeros[31:28];		//CARACTER 7 //160
			12'b001101000101: FontSelect = numeros[27:24];		//CARACTER 6 //208
			12'b010001000101: FontSelect = numeros[23:20];		//CARACTER 5 //272
			12'b010101000101: FontSelect = numeros[19:16];		//CARACTER 4 //336
			12'b011000000101: FontSelect = numeros[15:12];		//CARACTER 3
			12'b011100000101: FontSelect = numeros[11:8];		//CARACTER 2
			12'b100000000101: FontSelect = numeros[7:4];			//CARACTER 1
			12'b100011000101: FontSelect = numeros[3:0];			//CARACTER 0
			
			
			default: FontSelect = 4'b0;
		endcase
	
	always@(posedge clk)			//DECODIFICA CADA ENTRADA PARA DAR LA SALIDA EN 5BITS
		case(FontSelect)
			0: Pos = 5'd20;		//0
			1: Pos = 5'd21;		//1
			2: Pos = 5'd22;		//2
			3: Pos = 5'd23;		//3
			4: Pos = 5'd15;		//4
			5: Pos = 5'd16;		//5
			6: Pos = 5'd17;		//6
			7: Pos = 5'd18;		//7
			8: Pos = 5'd10;		//8
			9: Pos = 5'd11;		//9
			10: Pos = 5'd12;		//A
			11: Pos = 5'd13;		//B
			12: Pos = 5'd5;		//C
			13: Pos = 5'd6;		//D
			14: Pos = 5'd7;		//E
			15: Pos = 5'd8;		//F
			default: Pos = 5'd20;//DEFAULT 0
		endcase
endmodule
