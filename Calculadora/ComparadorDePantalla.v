
module ComparadorDePantalla(CuentaXalta,numeros,CuentaYalta, FontSelect);

input [5:0] CuentaXalta;		//CUENTA X ALTA DEL SINCRONIZADOR
input [5:0] CuentaYalta;		//CUENTA Y ALTA DEL SINCRONIZADOR
input [39:0] numeros;
output reg [4:0] FontSelect;			//SAlIDA DE SELECT PARA MEMORIA DE FONTS

 reg [4:0] Pos;
 reg [3:0] caracter;

always@(CuentaXalta or CuentaYalta or numeros)
	case({CuentaXalta,CuentaYalta})
		12'b000010000101: caracter = numeros[39:36];		//CARACTER 9 //32
		12'b000110000101: caracter = numeros[35:32];		//CARACTER 8 //96
		12'b001010000101: caracter = numeros[31:28];		//CARACTER 7 //160
		12'b001101000101: caracter = numeros[27:24];		//CARACTER 6 //208
		12'b010001000101: caracter = numeros[23:20];		//CARACTER 5 //272
		12'b010101000101: caracter = numeros[19:16];		//CARACTER 4 //336
		12'b011000000101: caracter = numeros[15:12];		//CARACTER 3
		12'b011100000101: caracter = numeros[11:8];		//CARACTER 2
		12'b100000000101: caracter = numeros[7:4];			//CARACTER 1
		12'b100011000101: caracter = numeros[3:0];			//CARACTER 0
		default: caracter = 4'b0;
	endcase		

	always@(caracter)			//DECODIFICA CADA ENTRADA PARA DARLE EL VALOR DEL FONT
		case(caracter)
			0: Pos = 5'd0;		//0
			1: Pos = 5'd1;		//1
			2: Pos = 5'd2;		//2
			3: Pos = 5'd3;		//3
			4: Pos = 5'd4;		//4
			5: Pos = 5'd5;		//5
			6: Pos = 5'd6;		//6
			7: Pos = 5'd7;		//7
			8: Pos = 5'd8;		//8
			9: Pos = 5'd9;		//9
			10: Pos = 5'd10;		//A
			11: Pos = 5'd11;		//B
			12: Pos = 5'd12;		//C
			13: Pos = 5'd13;		//D
			14: Pos = 5'd14;		//E
			15: Pos = 5'd15;		//F
			default: Pos = 5'd0;//DEFAULT 0
		endcase

always@(CuentaXalta or CuentaYalta or Pos)
	case({CuentaXalta,CuentaYalta})

		//////////////////////////////////////////////////////////////////// BLOQUE PANTALLITA
		12'b000010000101: FontSelect = Pos;		//CARACTER 9 //32
		12'b000110000101: FontSelect = Pos;		//CARACTER 8 //96
		12'b001010000101: FontSelect = Pos;		//CARACTER 7 //160
		12'b001101000101: FontSelect = Pos;		//CARACTER 6 //208
		12'b010001000101: FontSelect = Pos;		//CARACTER 5 //272
		12'b010101000101: FontSelect = Pos;		//CARACTER 4 //336
		12'b011000000101: FontSelect = Pos;		//CARACTER 3
		12'b011100000101: FontSelect = Pos;		//CARACTER 2
		12'b100000000101: FontSelect = Pos;			//CARACTER 1
		12'b100011000101: FontSelect = Pos;			//CARACTER 0
	
		//////////////////////////////////////////////////////////////////// 1ER BLOQUE
		12'b000011001111: FontSelect = 5'd25;		//CARACTER . 
		12'b000111001111: FontSelect = 5'd20;		//CARACTER RAIZ
		12'b001011001111: FontSelect = 5'd18;		//CARACTER x
		12'b001111001111: FontSelect = 5'd19;		//CARACTER /
		12'b010011001111: FontSelect = 5'd16;		//CARACTER + 
		12'b010111001111: FontSelect = 5'd17;		//CARACTER -
		12'b011100001111: FontSelect = 5'd23;		//CARACTER AC
		12'b100000001111: FontSelect = 5'd21;		//CARACTER BORRAR
		12'b100100001111: FontSelect = 5'd12;		//CARACTER CE DELETE
		
		//////////////////////////////////////////////////////////////////// 2DO BLOQUE
		12'b000011010100: FontSelect = 5'd8;		//CARACTER 8
		12'b000111010100: FontSelect = 5'd9;		//CARACTER 9
		12'b001011010100: FontSelect = 5'd10;		//CARACTER A
		12'b001111010100: FontSelect = 5'd11;		//CARACTER B
		12'b010011010100: FontSelect = 5'd12;		//CARACTER C
		12'b010111010100: FontSelect = 5'd13;		//CARACTER D
		12'b011100010100: FontSelect = 5'd14;		//CARACTER E
		12'b100000010100: FontSelect = 5'd15;		//CARACTER F
		12'b100100010100: FontSelect = 5'd22;		//CARACTER =
		
		//////////////////////////////////////////////////////////////////// 3ER BLOQUE
		12'b000011011010: FontSelect = 5'd0;		//CARACTER 0
		12'b000111011010: FontSelect = 5'd1;		//CARACTER 1
		12'b001011011010: FontSelect = 5'd2;		//CARACTER 2
		12'b001111011010: FontSelect = 5'd3;		//CARACTER 3
		12'b010011011010: FontSelect = 5'd4;		//CARACTER 4
		12'b010111011010: FontSelect = 5'd5;		//CARACTER 5
		12'b011100011010: FontSelect = 5'd6;		//CARACTER 6
		12'b100000011010: FontSelect = 5'd7;		//CARACTER 7
		default: FontSelect = 5'd24;					//CARACTER VACIO
	endcase 
endmodule 




//		12'b000011000111: FontSelect = 5'd16;		//CARACTER + //
//		12'b001011000111: FontSelect = 5'd17;		//CARACTER -
//		12'b010011000111: FontSelect = 5'd18;		//CARACTER x
//		12'b011011000111: FontSelect = 5'd19;		//CARACTER /
//		12'b100011000111: FontSelect = 5'd22;		//CARACTER =
//		
//		12'b000011001100: FontSelect = 5'd12;		//CARACTER C
//		12'b001011001100: FontSelect = 5'd13;		//CARACTER D
//		12'b010011001100: FontSelect = 5'd14;		//CARACTER E
//		12'b011011001100: FontSelect = 5'd15;		//CARACTER F
//		12'b100011001100: FontSelect = 5'd20;		//CARACTER RAIZ
//		
//		12'b000011010001: FontSelect = 5'd8;		//CARACTER 8
//		12'b001011010001: FontSelect = 5'd9;		//CARACTER 9
//		12'b010011010001: FontSelect = 5'd10;		//CARACTER A
//		12'b011011010001: FontSelect = 5'd11;		//CARACTER B
//		12'b100011010001: FontSelect = 5'd21;		//CARACTER BORRAR
//			
//		12'b000011010110: FontSelect = 5'd4;		//CARACTER 4
//		12'b001011010110: FontSelect = 5'd5;		//CARACTER 5
//		12'b010011010110: FontSelect = 5'd6;		//CARACTER 6
//		12'b011011010110: FontSelect = 5'd7;		//CARACTER 7
//		12'b100011010110: FontSelect = 5'd23;		//CARACTER AC
//		//  48-63  432-447    011100
//		12'b000011 011011: FontSelect = 5'd0;		//CARACTER 0
//		12'b001011 011011: FontSelect = 5'd1;		//CARACTER 1
//		12'b010011 011011: FontSelect = 5'd2;		//CARACTER 2
//		12'b011011 011011: FontSelect = 5'd3;		//CARACTER 3
//		12'b100011 011011: FontSelect = 5'd12;		//CARACTER C BORRAR
//		default: FontSelect = 5'd30;					//CARACTER VACIO
