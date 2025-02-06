//////////////////////////////////////////////////////////////////////////////////
// Name: Gabriel Rodriguez Palacios, Andres Carrillo Arroyo, 
//	 	 Steven Arias Gutierrez, Jose Calvo Elizondo 
// Create Date: 12.09.2021
// Project Name: Semaforo con 2 estados
//////////////////////////////////////////////////////////////////////////////////

`include "Modulo_principal.v"
`include "movimiento.v"
`include "Registro_Digitos_A.v"
`include "Registro_Digitos_B.v"
`include "BouncingButtom.v"
`include "ALU.v"

module tb_calcu;

// Inputs
 	reg CLK;
	reg RST;
 	reg BM,BA,BB,BD,BI;

// Outputs
	wire [39:0] QBAJO,S;
	wire COUT,DONE,over_mult,Over_Sum;
  	//wire H_SINC,V_SINC,RED,GREEN1,GREEN2,BLUE;
  //wire [1:0] pos1,pos2,pos3,pos4,pos5,pos6,pos7,pos8,pos9,QUIEN,Estado;
 
// Instantiate the Unit Under Test (UUT)
	Modulo_principal calc(CLK,RST,BM,BA,BB,BD,BI,COUT,DONE,over_mult,Over_Sum,QBAJO,S);
 // clock //Switches = T11,R11,N11,M11
 	 initial
      begin 
        $dumpfile("calc.vcd");
        $dumpvars(0,tb_calcu);
        CLK=0;
        RST=1;
        BA=0;
        BB=0;
        BI=0;
        BD=0;
        BM=0;
        #10
        RST=0;

//        //inicio de juego

        #20
        BA=1;
        #20
        BA=0;
        #20
        BM=1;//presiona 8
        #20
        BM=0;
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
        
		  BM=1;//presiona B
        #20
        BM=0;
        #20
		  
		  BA=1;
        #20
        BA=0;
        #20
        BM=1;//presiona /
        #20
        BM=0;
		  #20
		  
		  BB=1;
        #20
        BB=0;
        #20
        BM=1;//presiona B
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
