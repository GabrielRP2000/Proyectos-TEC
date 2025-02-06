`timescale 1ns / 1ps

module ComparadorBorde(CuentaX, CuentaY, X, Y);

input [9:0] CuentaX;		//CUENTA X DEL SINCRONIZADOR
input [9:0] CuentaY;		//CUENTA Y DEL SINCRONIZADOR
output reg [4:0] X;			//SALIDA PARA EL DECO EN X
output reg [3:0] Y;			//SALIDA PARA EL DECO EN Y

always@(CuentaX)
	if((CuentaX>=10'd0)&&(CuentaX<10'd22)) //25-32
		X = 5'b0000;//0
	else if((CuentaX>=10'd83)&&(CuentaX<10'd89))
		X = 5'b0001;//1
	else if((CuentaX>=10'd150)&&(CuentaX<10'd156))
		X = 5'b0010;//2
	else if((CuentaX>=10'd217)&&(CuentaX<10'd223))		//bordes derecho izquierdo de botones
		X = 5'b0011;//3
	else if((CuentaX>=10'd284)&&(CuentaX<10'd290))
		X = 5'b0100;//4
	else if((CuentaX>=10'd351)&&(CuentaX<10'd357))
		X = 5'b0101;//5
	else if((CuentaX>=10'd418)&&(CuentaX<10'd424))
		X = 5'b0110;//6
	else if((CuentaX>=10'd485)&&(CuentaX<10'd491))
		X = 5'b0111;//7
	else if((CuentaX>=10'd552)&&(CuentaX<10'd558))
		X = 5'b1000;//8
	else if((CuentaX>=10'd619)&&(CuentaX<10'd640))
		X = 5'b1001;//9
		
	else if((CuentaX>=10'd44)&&(CuentaX<10'd60))   //ANIMACION SELECCION para 9 botones
		X = 5'b1010;//10
	else if((CuentaX>=10'd111)&&(CuentaX<10'd127))
		X = 5'b1011;//11
	else if((CuentaX>=10'd178)&&(CuentaX<10'd194))
		X = 5'b1100;//12
	else if((CuentaX>=10'd245)&&(CuentaX<10'd261))
		X = 5'b1101;//13
	else if((CuentaX>=10'd312)&&(CuentaX<10'd328))
		X = 5'b1110;//14
	else if((CuentaX>=10'd379)&&(CuentaX<10'd395))   //ANIMACION SELECCION para 9 botones
		X = 5'b01111;//15
	else if((CuentaX>=10'd446)&&(CuentaX<10'd462))
		X = 5'b10000;//16
	else if((CuentaX>=10'd513)&&(CuentaX<10'd529))
		X = 5'b10001;//17
	else if((CuentaX>=10'd580)&&(CuentaX<10'd596))
		X = 5'b10010;//18
	
	else 
		X = 5'b11111;		//DEFAULT

always@(CuentaY)
	if((CuentaY>=10'd0)&&(CuentaY<10'd20))
		Y = 4'b000;
	else if((CuentaY>=10'd20)&&(CuentaY<10'd201))
		Y = 4'b001;
	else if((CuentaY>=10'd201)&&(CuentaY<10'd207))
		Y = 4'b010;
	else if((CuentaY>=10'd285)&&(CuentaY<10'd291))		//bordes arriba y abajo de botones
		Y = 4'b011;
	else if((CuentaY>=10'd374)&&(CuentaY<10'd379))		//bordes arriba y abajo de botones
		Y = 4'b100;
	else if((CuentaY>=10'd462)&&(CuentaY<10'd486))
		Y = 4'b101;//5
	
	
	
	else if((CuentaY>=10'd271)&&(CuentaY<10'd278))
		Y = 4'b1000;//8
	else if((CuentaY>=10'd360)&&(CuentaY<10'd367))
		Y = 4'b111;//7
	else if((CuentaY>=10'd448)&&(CuentaY<10'd455))
		Y = 4'b110;//6
		
	else 
		Y = 4'b1111;		//DEFAULT

endmodule 




//module ComparadorBorde(CuentaX, CuentaY, X, Y);
//
//input [9:0] CuentaX;		//CUENTA X DEL SINCRONIZADOR
//input [9:0] CuentaY;		//CUENTA Y DEL SINCRONIZADOR
//output reg [3:0] X;			//SALIDA PARA EL DECO EN X
//output reg [3:0] Y;			//SALIDA PARA EL DECO EN Y
//
//always@(CuentaX)
//	if((CuentaX>=10'd10)&&(CuentaX<10'd22)) //25-32
//		X = 4'b0000;
//	else if((CuentaX>=10'd117)&&(CuentaX<10'd123))
//		X = 4'b0001;
//	else if((CuentaX>=10'd245)&&(CuentaX<10'd252))
//		X = 4'b0010;
//	else if((CuentaX>=10'd373)&&(CuentaX<10'd379))		//bordes derecho izquierdo de botones
//		X = 4'b0011;
//	else if((CuentaX>=10'd501)&&(CuentaX<10'd507))
//		X = 4'b0100;
//	else if((CuentaX>=10'd619)&&(CuentaX<10'd630))
//		X = 4'b0101;
//		
//		
//	else if((CuentaX>=10'd48)&&(CuentaX<10'd64))
//		X = 4'b1000;
//	else if((CuentaX>=10'd176)&&(CuentaX<10'd192))
//		X = 4'b1001;
//	else if((CuentaX>=10'd304)&&(CuentaX<10'd320))   //ANIMACION SELECCION X
//		X = 4'b1010;
//	else if((CuentaX>=10'd432)&&(CuentaX<10'd448))
//		X = 4'b1011;
//	else if((CuentaX>=10'd560)&&(CuentaX<10'd576))
//		X = 4'b1100;
//		
//	else 
//		X = 4'b1111;		//DEFAULT
//
//always@(CuentaY)
//	if((CuentaY>=10'd0)&&(CuentaY<10'd20))
//		Y = 4'b0000;
//	else if((CuentaY>=10'd20)&&(CuentaY<10'd67))
//		Y = 4'b0001;
//	else if((CuentaY>=10'd67)&&(CuentaY<10'd73))
//		Y = 4'b0010;
//	else if((CuentaY>=10'd147)&&(CuentaY<10'd153))		//bordes arriba y abajo de botones
//		Y = 4'b0011;
//	else if((CuentaY>=10'd227)&&(CuentaY<10'd233))
//		Y = 4'b0100;
//	else if((CuentaY>=10'd307)&&(CuentaY<10'd313))
//		Y = 4'b0101;
//	else if((CuentaY>=10'd387)&&(CuentaY<10'd393))
//		Y = 4'b0110;
//	else if((CuentaY>=10'd462)&&(CuentaY<10'd486))
//		Y = 4'b0111;
//		
//	else if((CuentaY>=10'd80)&&(CuentaY<10'd85))
//		Y = 4'b1000;
//	else if((CuentaY>=10'd160)&&(CuentaY<10'd165))
//		Y = 4'b1001;
//	else if((CuentaY>=10'd240)&&(CuentaY<10'd245))		//ANIMACION SELECCION Y
//		Y = 4'b1010;
//	else if((CuentaY>=10'd320)&&(CuentaY<10'd325))	
//		Y = 4'b1011;
//	else if((CuentaY>=10'd400)&&(CuentaY<10'd405))
//		Y = 4'b1100;		
//		
//	else 
//		Y = 4'b1111;		//DEFAULT
//
//endmodule 
