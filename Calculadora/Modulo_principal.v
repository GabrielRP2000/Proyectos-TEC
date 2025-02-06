//////////////////////////////////////////////////////////////////////////////////
// Name: Gabriel Rodriguez Palacios, Jose Calvo Elizondo 
// Create Date: 12.09.2021
// Project Name: Semaforo con 2 estados
//////////////////////////////////////////////////////////////////////////////////

module Modulo_principal(CLK,RST,I1,I2,I3,I4,BM,BA,BB,BD,BI,HSYNC,VSYNC,ROJO1,AZUL,VERDE,ROJO2);//,B);//S1,S2,S3,S4,H_SINC,V_SINC,RED,GREEN1,GREEN2,BLUE
   input CLK,RST,BM,BA,BB,BD,BI,I1,I2,I3,I4;//,S1,S2,S3,S4;
	output wire HSYNC,VSYNC,ROJO1,AZUL,VERDE,ROJO2;
	
  	wire [25:0] POS_actual;// 01: A  y  10: B
  	wire [1:0] Estado;
	wire [2:0] OP;
	wire ba,bb,bi,bd,bm,RetraST,B_Listo,COUT,DONE,CE,COUT1,DONE1;
	wire [39:0] reg_A,reg_B,RetrasoB,QBAJO,S,RaizOUT,Numeros;
	wire [4:0] POS;
	wire TEMPHSYNC, TEMPVSYNC;
	wire [3:0] COLOR;
	wire [3:0] S_color;
	
	assign ROJO1 = S_color[3];			//COLOR	ROJO1 
	assign VERDE = S_color[2];			//COLOR VERDE 1
	assign AZUL = S_color[1];			//COLOR AZUL	
	assign ROJO2 = S_color[0];			//COLOR ROJO CLARO
	assign COLOR = {I1,I2,I3,I4};
	assign HSYNC = ~TEMPHSYNC;
	assign VSYNC = ~TEMPVSYNC;

//module BouncingButtom(CLK,RESET,BOT,BOTOUT);
 BouncingButtom botonA(.CLK(CLK),.RESET(RST),.BOT(BA),.BOTOUT(ba));
 BouncingButtom botonB(.CLK(CLK),.RESET(RST),.BOT(BB),.BOTOUT(bb));
 BouncingButtom botonI(.CLK(CLK),.RESET(RST),.BOT(BI),.BOTOUT(bi));
 BouncingButtom botonD(.CLK(CLK),.RESET(RST),.BOT(BD),.BOTOUT(bd));
 BouncingButtom botonM(.CLK(CLK),.RESET(RST),.BOT(BM),.BOTOUT(bm));
 
 assign CE = bm & POS_actual[24];
//module movimiento(clk,BA,BB,BI,BD,pos_actual,Pos);
 movimiento movio(.clk(CLK),.BA(ba),.BB(bb),.BI(bi),.BD(bd),.pos_actual(POS_actual),.Pos(POS));
//module fsm_control(clk,rst,BM,pos_actual,estado,START,OP);
 fsm_control maquinita(.clk(CLK),.rst(RST|CE),.BM(bm),.pos_17_21(POS_actual[21:17]),.pos_24_25(POS_actual[25:24]),.estado(Estado),.OP(OP));//.START(START),
//module Registro_Digitos_A(clock,reset,BM,pos_actual,estado,A);
 Registro_Digitos_A regA(.clock(CLK),.reset(RST|CE),.BM(bm),.C(CE),.pos_actual(POS_actual),.estado(Estado),.A(reg_A));
//module Registro_Digitos_B(clock,reset,BM,pos_actual,estado,B);
 Registro_Digitos_B regB(.clock(CLK),.reset(RST|CE),.BM(bm),.C(CE),.pos_actual(POS_actual),.estado(Estado),.B(reg_B));
//module ALU (CLK,RST,START,OP,estado,A,B,DONE,COUT,QBAJO,S);
 ALU alu (.CLK(CLK),.RST(RST|CE),.START(RetraST),.OP(OP[1:0]),.estado(Estado),.listoB(B_Listo),.registro_A(reg_A),.registro_B(RetrasoB),.COUT(COUT),.DONE(DONE),.QBAJO(QBAJO),.S(S));
//module Retraso_start_B(clk,rst,Start,estado,retraST);
 Retraso_start_B retraso(.clk(CLK),.rst(RST|CE),.estado(Estado),.inB(reg_B),.listoB(B_Listo),.retraST(RetraST),.retraB(RetrasoB)); //,.inB(reg_B),.retraB(RetraB)
//module pantalla_calcu(clk,rst,OP,CuentaXalta,CuentaYalta,reg_A,reg_B,estado,raiz,Sum_Res,Mult_Div,COUT,DONE,numeros);
 pantalla_calcu  pantallita_calcu (.clk(CLK),.OP(OP),.reg_A(reg_A),.reg_B(reg_B),.estado(Estado),.raiz(RaizOUT),
												.Sum_Res(S),.Mult_Div(QBAJO),.COUT(COUT|COUT1),.DONE(DONE|DONE1),.numeros1(Numeros));
//module Pantalla(CLK,RESET,COLOR,POS,numeros,Hsync,Vsync,RGB);
 Pantalla VGA(.CLK(CLK),.RESET(RST|CE),.COLOR(COLOR),.POS(POS),.numeros(Numeros),.Hsync(TEMPHSYNC),.Vsync(TEMPVSYNC),.RGB(S_color));
//module RaizCuadrada(CLK,RST,START,OP,IN,OUT,COUT,DONE);
 RaizCuadrada raiz(.CLK(CLK),.RST(RST|CE),.START(RetraST),.OP(OP),.IN(RetrasoB),.OUT(RaizOUT),.COUT(COUT1),.DONE(DONE1));

endmodule

//module CalculadoraHexadecimal(CLK, RESET,I1,I2,I3,I4,BOTARRIN,BOTABAIN,BOTDERIN,BOTIZQIN,numeros, HSYNC, VSYNC, ROJO1,AZUL,VERDE,ROJO2);
//CalculadoraHexadecimal vga(.CLK(CLK),.RESET(RST),.I1(I1),.I2(I2),.I3(I3),.I4(I4),.POS(POS),.BOTARRIN(BA),.BOTABAIN(BB),.BOTDERIN(BD),.BOTIZQIN(BI),
//								.numeros(Numeros),.HSYNC(HSYNC),.VSYNC(VSYNC),.ROJO1(ROJO1),.AZUL(AZUL),.VERDE(VERDE),.ROJO2(ROJO2));