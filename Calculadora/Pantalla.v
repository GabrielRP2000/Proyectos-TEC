
module Pantalla(CLK,RESET,COLOR,POS,numeros,Hsync,Vsync,RGB);

input CLK, RESET;
input [3:0] COLOR;
input [4:0] POS;
input [39:0] numeros;
output Hsync, Vsync;
output [3:0] RGB;

wire [9:0] CuentaX,CuentaY;
wire [3:0] Blanco,S;
wire [4:0] FSelect;
wire [15:0] Fila;
wire OUT,Borde;
wire [4:0] X;
wire [3:0] Y;


Controlador_VGA SINCRONIZADOR(CLK, RESET, Hsync, Vsync, CuentaX, CuentaY);

//module ComparadorDePantalla(CuentaXalta[6],numeros,CuentaYalta[6], FontSelect[5]);
ComparadorDePantalla FONTSELECTOR (CuentaX[9:4],numeros,CuentaY[9:4], FSelect);

Fonts FONTS(FSelect,CuentaY[3:0],Fila);

//module MuxRGB(A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15[1],SEL[4],OUT[1]);	(sel=0000)->(out=A0)  	//MUX DE 16 A 1 para pintar el font
MuxRGB MUXRGB(Fila[15],Fila[14],Fila[13],Fila[12],Fila[11],Fila[10],Fila[9],Fila[8],Fila[7],Fila[6],Fila[5],Fila[4],Fila[3],Fila[2],Fila[1],Fila[0],CuentaX[3:0],OUT);

//module Comparador4bits(B[1],S[4]);	//COMPARA SI EL BIT ES 1 O 0 PARA PINTAR
Comparador4bits BOTONES(OUT,S);	

ComparadorBorde BORDE(CuentaX,CuentaY, X, Y);

//module DegoBorde(X[5],Y[4],POS[5],Borde[1]);
DegoBorde BORDESELECT(X,Y,POS,Borde);

//module MuxPantalla(A[4],B[4],S,OUT[4]);		para pintar los bordes segun switches
MuxPantalla MUXPANTALLA(COLOR,S,Borde,RGB);

//module Compa_Pant_calc(clk,CuentaXa,CuentaYa,numeros,Pos);
//Compa_Pant_calc  pantallaCalcu(.clk(CLK),.CuentaXa(CuentaX[9:4]),.CuentaYa(CuentaY[9:4]),.numeros(numeros),.Pos(POS));

endmodule
