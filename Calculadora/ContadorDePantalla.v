`timescale 1ns / 1ps

module ContadorDePantalla(CLK,Res,Aumenta,Disminuye,Cuenta);

input CLK;				//INPUTS
input Res;				//BOTOON RESET
input Aumenta;			//BOTON PARA AUMENTAR POSICION
input Disminuye;		//BOTON PARA DISMINUIR POSICION

output reg[2:0] Cuenta;			//VARIABLE PARA LLEVAR CUENTA

always@(posedge CLK or posedge Res)			//CADA CLK O RESET
		if(Res)
			Cuenta = 3'd0;
		else if(Aumenta && (Cuenta <4))			//AUMENTA O DISMINUYE DEPENDIENDO DEL BOTON
			Cuenta = Cuenta + 3'd1;	
		else if(Disminuye && (Cuenta>0))
			Cuenta = Cuenta - 3'd1;
		else
			Cuenta = Cuenta;
			
endmodule
