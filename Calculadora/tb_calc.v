
`include "Modulo_principal.v"
`include "movimiento.v"
`include "Registro_Digitos_A.v"
`include "Registro_Digitos_B.v"
`include "BouncingButtom.v"
`include "ALU.v"


module tb_calc;

	// Inputs
	reg CLK;
	reg RST;
	reg I1;
	reg I2;
	reg I3;
	reg I4;
	reg BM;
	reg BA;
	reg BB;
	reg BD;
	reg BI;

	// Outputs
	wire HSYNC;
	wire VSYNC;
	wire ROJO1;
	wire AZUL;
	wire VERDE;
	wire ROJO2;

	// Instantiate the Unit Under Test (UUT)
	Modulo_principal uut (
		.CLK(CLK), 
		.RST(RST), 
		.I1(I1), 
		.I2(I2), 
		.I3(I3), 
		.I4(I4), 
		.BM(BM), 
		.BA(BA), 
		.BB(BB), 
		.BD(BD), 
		.BI(BI), 
		.HSYNC(HSYNC), 
		.VSYNC(VSYNC), 
		.ROJO1(ROJO1), 
		.AZUL(AZUL), 
		.VERDE(VERDE), 
		.ROJO2(ROJO2)
	);

	initial begin
		// Initialize Inputs
		CLK = 0;
		RST = 1;
		I1 = 0;
		I2 = 0;
		I3 = 0;
		I4 = 0;
		BM = 0;
		BA = 0;
		BB = 0;
		BD = 0;
		BI = 0;
		
		
		#200
		RST = 0;	
		I1 = 1;
	
		#20
      BA=1;
      #20
      BA=0;
      #20
//      BM=1;//presiona 8
//      #20
//      BM=0;
//      #20
		
		#20
		BD=1;
      #20
      BD=0;
		BM=1;//presiona 9
      #20
      BM=0;
      #20
		 
		#20
		BA=1;
      #20
      BA=0;
      #20
      BM=1;//presiona Raiz
      #20
      BM=0;
		#20
		 
		#20
		BB=1;
      #20
      BB=0;
      #20
      BM=1;//presiona 9
      #20
      BM=0;
		#20
		
		#20
		BD=1;
      #20
      BD=0;
		#20
      BD=1;
      #20
		BD=0;
		#20
      BD=1;
      #20
      BD=0;
		#20
		BD=1;
      #20
      BD=0;
		#20
      BD=1;
      #20
      BD=0;
		#20
      BD=1;
      #20
      BD=0;
		#20
      BD=1;
      #20
      BD=0;
		#20
      BM=1;//presiona =
      #20
      BM=0;
      #20
		
      #50000 $finish;
	end
   initial
		forever 
			#1 CLK=~CLK;
endmodule

