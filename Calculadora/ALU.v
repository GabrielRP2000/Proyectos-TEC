
module ALU(CLK,RST,START,OP,estado,listoB,registro_A,registro_B,DONE,COUT,QBAJO,S);
	
	input CLK,RST,START,listoB;
	input [1:0] OP,estado;
	input [39:0] registro_A,registro_B;
	output wire [39:0] QBAJO;//respuesta de multiplicacion y division
	output wire [39:0]S;
	output wire DONE,COUT;
	
	wire [39:0] QALTO;
//	assign over_mult = |QALTO;//para tener en la salida el overflow de la multiplicacion
//para registrar en IN = A o B segun el estado en el que se encuentre
	reg [39:0] IN;
	
	always @(posedge CLK)
	begin
		if(RST)
			IN = 40'b0;
		else if ((estado[1] == 1'b0 && estado[0] == 1'b1)||(estado[1] == 1'b1 && estado[0] == 1'b0))
			IN = registro_A;
		else if (listoB)
			IN = registro_B;
		else
			IN = IN;
	end

//Instanciar
	wire ENAR1, ENAR2;
	wire [39:0] B0,A;
	Registro40bitsEna R1(CLK,RST,ENAR2,IN,A);
	Registro40bitsEna R2(CLK,RST,ENAR1,IN,B0);

	//Mux
	wire [39:0]B;
	Mux2a1de40bits MuxA(B0,QALTO,OP[1],B);
	//Sumador Restador
	//wire [39:0] S;
	SumadorRestador SR(B,A,OP[0],S,COUT);
	//Registro Desp
	wire WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput;
	RegDesp RD(CLK,RST,WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput,S,IN,QALTO,QBAJO);

	//LSB Y MSB
	wire LSB,MSB;
	assign LSB = QBAJO[0];
	assign MSB = S[39];
	//CONTADOR
	wire ENAC,Z,RSTC;
	Contador3bits CONT(CLK,(RST|RSTC),OP[0],ENAC,Z);
	
	//FSM ALU
	FSMALU FSM(CLK,RST,START,OP,LSB,MSB,ENAR1,ENAR2,WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput,ENAC,Z,RSTC,DONE);
endmodule

module Contador3bits(CLK,RST,OP,ENA,Z);
	
	input CLK,RST,OP,ENA;
	output wire Z;
	
	reg[5:0]Q;
	
	always @(posedge CLK)
		if(RST)
			Q={5'b10100,OP};
		else if (ENA)
			Q=Q-1'b1;
		else
			Q=Q;

	assign Z= ~|Q;
endmodule

module Registro40bitsEna(CLK,RST,ENA,D,Q);

    input CLK,RST,ENA;
    input [39:0] D;
    output reg [39:0] Q;

    always @(posedge CLK or posedge RST) 
        if(RST)
            Q=39'd0;

        else if (ENA)
            Q=D;
        else 
            Q=Q;

endmodule

module Mux2a1de40bits(A,B,OP,OUT);

    input [39:0] A,B;
    input OP;
    output reg [39:0] OUT;

    always @(OP or A or B)
        case (OP)
            1'b0: OUT=A;
            1'b1: OUT=B; 
        endcase

endmodule

module SumadorRestador(A,B,OP,S,Cout);

input [39:0] A,B;
input OP;
output wire [39:0] S;
output wire Cout; 
wire [39:0] XorOut;
XORde40bits myXOR(B,{OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP,OP},XorOut);

FullAdder40bits FA(A,XorOut,OP,S,Cout);
//assign Over_Sum = (Cout)^(C38);

endmodule 


module RegDesp(CLK,RST,WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput,DALTO,DBAJO,QALTO,QBAJO);
	input CLK,RST;
	input WRALTO,WRBAJO;
	input SHLEFT,SHRIGHT;
	input DivInput;
	input [39:0] DALTO;
	input [39:0] DBAJO;
	output wire [39:0] QALTO;
	output wire [39:0] QBAJO;
	
	reg [79:0] Q;
	always @(posedge CLK or posedge RST)
		if(RST)
			Q=80'b0;
		else if (WRALTO)
			Q={DALTO,QBAJO};
		else if (WRBAJO)
			Q={QALTO,DBAJO};
		else if (SHLEFT)
			Q={Q[78:0],DivInput};
		else if (SHRIGHT)
			Q={1'b0,Q[79:1]};
		else
			Q=Q;

	assign QALTO = Q[79:40];
	assign QBAJO = Q[39:0];
endmodule 

module FSMALU(CLK,RST,START,OP,LSB,MSB,ENAR1,ENAR2,WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput,ENAC,Z,RSTC,DONE);

	input CLK,RST,START,LSB,MSB,Z;
	input [1:0]OP;
	output ENAR1,ENAR2,WRALTO,WRBAJO,SHLEFT,SHRIGHT,DivInput,ENAC,RSTC,DONE;
		
	//vars y parameters
	reg [2:0] PRE,FUT;
	parameter T0=3'b000, T1=3'b001,T2=3'b010,T3=3'b011,T4=3'b100,T5=3'b101,T6=3'b110,T7=3'b111;
	
	//Transicion de Estados
	always @(negedge CLK or posedge RST)
		if (RST)
				PRE = T0;
		else
				PRE=FUT;
			//Red del estado Futuro
	always @(PRE or START or Z or OP)
		case(PRE)
			T0: if(START) //seguimos si start
				FUT= T1;
			    else
			FUT = T0;
			T1: FUT=T2;
			T2: FUT=T3;
			T3: FUT=T4;
			T4: if (Z|~OP[1])
				FUT= T7;
			    else
				FUT = T3;
			T5: FUT=T7;
			T6: FUT=T7;
			T7: FUT=T0;
		endcase
		//Deco de salida
	reg WR,SH;
	reg ENAR1,ENAR2,ENAC,RSTC,DONE;
	assign WRBAJO=ENAR1;
	
	always @(PRE)
		case(PRE)
		   T0:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0000010;
			T1:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0010000;
			T2:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0001000;
			T3:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b1000100;
			T4:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0100000;
			T5:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0000000;
			T6:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0000000;
			T7:{WR,SH,ENAR1,ENAR2,ENAC,RSTC,DONE} = 7'b0000001;
		endcase
		//Red de asignacion de salida
	wire WRALTO;
	assign WRALTO= ( (OP[0]&~MSB) | (~OP[0]&LSB) | (~OP[1])) & WR;
	wire SHLEFT,SHRIGHT;
	assign SHLEFT = OP[1]&OP[0]&SH;
	assign SHRIGHT = OP[1]&~OP[0]&SH;

	//FFD
	reg DivInput;
	always @(posedge CLK)
		DivInput = ~MSB;
endmodule


module XORde40bits(A, B, OUT);

	//Definicion de Input and Output
	input [39:0] A, B;
	output wire [39:0] OUT;
	assign OUT = A ^ B;

endmodule

module FullAdder40bits(A,B,Cin,S,Cout);
    
    input [39:0] A,B;
    input Cin;
    output wire [39:0] S;
    output wire Cout;

    wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21;
	 wire C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C34,C35,C36,C37,C38;

    //FULLADDERS
    FullAdder SC0(A[0],B[0],Cin,S[0],C0);
    FullAdder SC1(A[1],B[1],C0,S[1],C1);
    FullAdder SC2(A[2],B[2],C1,S[2],C2);
	 FullAdder SC3(A[3],B[3],C2,S[3],C3);
    FullAdder SC4(A[4],B[4],C3,S[4],C4);
    FullAdder SC5(A[5],B[5],C4,S[5],C5);
    FullAdder SC6(A[6],B[6],C5,S[6],C6);
    FullAdder SC7(A[7],B[7],C6,S[7],C7);
	 FullAdder SC8(A[8],B[8],C7,S[8],C8);
	 FullAdder SC9(A[9],B[9],C8,S[9],C9);
	 FullAdder SC10(A[10],B[10],C9,S[10],C10);
	 FullAdder SC11(A[11],B[11],C10,S[11],C11);
	 FullAdder SC12(A[12],B[12],C11,S[12],C12);
	 FullAdder SC13(A[13],B[13],C12,S[13],C13);
	 FullAdder SC14(A[14],B[14],C13,S[14],C14);
	 FullAdder SC15(A[15],B[15],C14,S[15],C15);
	 FullAdder SC16(A[16],B[16],C15,S[16],C16);
	 FullAdder SC17(A[17],B[17],C16,S[17],C17);
    FullAdder SC18(A[18],B[18],C17,S[18],C18);
	 FullAdder SC19(A[19],B[19],C18,S[19],C19);
	 FullAdder SC20(A[20],B[20],C19,S[20],C20);
	 FullAdder SC21(A[21],B[21],C20,S[21],C21);
	 FullAdder SC22(A[22],B[22],C21,S[22],C22);
	 FullAdder SC23(A[23],B[23],C22,S[23],C23);
	 FullAdder SC24(A[24],B[24],C23,S[24],C24);
	 FullAdder SC25(A[25],B[25],C24,S[25],C25);
	 FullAdder SC26(A[26],B[26],C25,S[26],C26);
	 FullAdder SC27(A[27],B[27],C26,S[27],C27);
	 FullAdder SC28(A[28],B[28],C27,S[28],C28);
	 FullAdder SC29(A[29],B[29],C28,S[29],C29);
	 FullAdder SC30(A[30],B[30],C29,S[30],C30);
	 FullAdder SC31(A[31],B[31],C30,S[31],C31);
	 FullAdder SC32(A[32],B[32],C31,S[32],C32);
	 FullAdder SC33(A[33],B[33],C32,S[33],C33);
	 FullAdder SC34(A[34],B[34],C33,S[34],C34);
	 FullAdder SC35(A[35],B[35],C34,S[35],C35);
	 FullAdder SC36(A[36],B[36],C35,S[36],C36);
	 FullAdder SC37(A[37],B[37],C36,S[37],C37);
	 FullAdder SC38(A[38],B[38],C37,S[38],C38);
	 FullAdder SC39(A[39],B[39],C38,S[39],Cout);
	
endmodule

module FullAdder(A,B,Cin,S,Cout);

    //in and out
    input A,B,Cin;
    output wire S, Cout;

    //Redes Intermedias
    wire XOR1,AND1,AND2;

    //Asignacion
    assign XOR1 = A ^ B;
    assign AND1 = A & B;
    assign AND2 = XOR1 & Cin;

    //Asiganaciones de Salida
    assign S = XOR1 ^ Cin;
    assign Cout = AND1 | AND2;
    
endmodule 
