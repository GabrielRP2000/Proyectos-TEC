`timescale 1ns / 1ps


//intrucciones de op
// op=000000 => ADD  //// de aqui
// op=000001 => OR
// op=000010 => ADC
// op=000011 => SBB
// op=000100 => AND
// op=000101 => SUB
// op=000110 => XOR /// hasta aqui ocupa 2 A
// op=000111 => CMP
// op=001000 => ROL
// op=001001 => ROR //// de aqui
// op=001010 => RCL
// op=001011 => RCR
// op=001100 => SHL //afectados por el V
// op=001101 => SHR
// op=001110 => SAL
// op=001111 => SAR ///hasta aqui
// op=010000 => AAA
// op=010101 => AAS
// op=011000 => DAA
// op=011101 => DAS
// op=100000 => MUL	8BITS     ///de aqui
// op=100001 => MUL  16BITS 
// op=100010 => IMUL 8BITS
// op=100011 => IMUL 16BITS   ///hasta aqui ocupa 2 A
// op=100100 => DIV  8BITS    //// de aqui
// op=100101 => DIV  16BITS
// op=100110 => IDIV 8BITS
// op=100111 => IDIV 16BITS   //hasta aqui ocupa 3 A
// op=101000 => NOT
// op=101001 => NEG
// op=101100 => CBW
// op=101101 => CWD
// op=101110 => AAM
// op=101111 => AAD

module ALU(CLK,RST,A,V,op,WA,WB,WD,WR,ENADi,opFL,R1,R2,FLAGS,FL,FINP,IF);
	input CLK,RST;
	input [15:0] A;
	input V;
	input [5:0] op;
	input WA,WB,WD,ENADi;
	input [1:0] WR;
	input [2:0] opFL;
	output wire [15:0] R1,R2,FLAGS;
	output wire [5:0] FL;
	output wire FINP,IF;

//Registros de entrada
	wire [15:0] opA,opB,opD,R;
	Reg16bitsEnaDown REGA(CLK,RST,WA,A,opA);
	Reg16bitsEnaDown REGB(CLK,RST,WB,A,opB);
	Reg16bitsEnaDown REGD(CLK,RST,WD,A,opD);
	
//Modulo ALU de Ajuste
	wire [15:0] AA,BA;
	wire CFC,AFC;
	AjustBasicModule Ajuste(opA,opB,op[4:3],FLAGS[0],FLAGS[4],AA,BA,CFC,AFC);
	
//Modulo de ALU1 (Tipo A)
	wire [15:0] RA;
	wire CFA,AFA,OFA;
	ALU1module ALU1(AA,BA,FLAGS[0],op[2:0],RA,CFA,AFA,OFA);

//Modulo de ALU2 (Tipo C)
	wire [15:0] RB;
	wire CFB,OFB;
	ALU2module ALU2(opA,opB[3:0],V,FLAGS[0],op[2:0],RB,CFB,OFB);

//Modulo Unidad Producto
	wire [15:0]opR1;
	wire OFD,CFD;
	UnidadProducto UnidPro(CLK,RST,ENADi,opA,opB,opD,op[3:0],opR1,R2,OFD,CFD,FINP);
	
//Mux de Salida
	wire CF,OF,AF;
	Mux4a1de16bits MuxSal(RA,RB,{RA[15:8],4'b0,RA[3:0]},RA,op[4:3],R);
	Mux2a1de16bits MuxSalFinal(R,opR1,op[5],R1);
	
	Mux8a1de1bit MuxCF(CFA,CFB,CFC,CFC,CFD,CFD,1'b0,1'b0,op[5:3],CF);
	Mux8a1de1bit MuxOF(OFA,OFB,OFA,OFA,OFD,OFD,1'b0,1'b0,op[5:3],OF);
	Mux4a1de1bit MuxAF(AFA,AFA,AFC,AFC,op[4:3],AF);
	
//Registro de Banderas	
	assign FLAGS[1]=1'b0,FLAGS[3]=1'b0,FLAGS[5]=1'b0,FLAGS[8]=1'b0,
			 FLAGS[12]=1'b0,FLAGS[13]=1'b0,FLAGS[14]=1'b0,FLAGS[15]=1'b0;
	
	wire P,Z,S;
	DetectorParidad Parid(R1,P);
	DetectorZero Zer(R1,Z);
	assign S=R1[15];
	
//Muxes y Registros
	wire CFR,PR,AFR,ZR,SR,OFR;
	assign CFR=(CF&~WR[1])|(A[0]&WR[1]);
	assign PR=(P&~WR[1])|(A[2]&WR[1]);
	assign AFR=(AF&~WR[1])|(A[4]&WR[1]);
	assign ZR=(Z&~WR[1])|(A[6]&WR[1]);
	assign SR=(S&~WR[1])|(A[7]&WR[1]);
	assign OFR=(OF&~WR[1])|(A[11]&WR[1]);
	
	wire RSTCF,RSTDF,RSTIF,SETCF,SETDF,SETIF,TOGCF;
	RomopFL RomdeopFL(opFL,RSTCF,RSTDF,RSTIF,SETCF,SETDF,SETIF,TOGCF);
	
	Reg1bitEnaSetTogDown REGF0(CLK,RST|RSTCF,(WR[1]|WR[0]),SETCF,TOGCF,CFR,FLAGS[0]);	//CF
	Reg1bitEnaDown REGF2(CLK,RST,(WR[1]|WR[0]),PR,FLAGS[2]);										//PF
	Reg1bitEnaDown REGF4(CLK,RST,(WR[1]|WR[0]),AFR,FLAGS[4]);									//AF
	Reg1bitEnaDown REGF6(CLK,RST,(WR[1]|WR[0]),ZR,FLAGS[6]);										//ZF
	Reg1bitEnaDown REGF7(CLK,RST,(WR[1]|WR[0]),SR,FLAGS[7]);										//SF
	RegIfEnaSetDown REGF9(CLK,RST,RSTIF,(WR[1]&~WR[0]),SETIF,A[9],FLAGS[9]);				//IF
	Reg1bitEnaSetDown REGF10(CLK,RST|RSTDF,(WR[1]&~WR[0]),SETDF,A[10],FLAGS[10]);			//DF
	Reg1bitEnaDown REGF11(CLK,RST,(WR[1]^WR[0]),OFR,FLAGS[11]);									//OF
	
	//los registros OF,DF,IF deben escribirse solo con WR=2'b10;
	
	assign FL={FLAGS[10],FLAGS[0],FLAGS[6],FLAGS[7],FLAGS[11],FLAGS[2]};
	assign IF=FLAGS[9];			
					//FL=DF,IF,CF,ZF,SF,OF,PF
					
endmodule

module ACT16bits(A,OP,R);
	input [15:0] A;
	input OP;
	output reg [15:0] R;
	
	always @(A or OP)
		case (OP)
			1'b0: R=16'b0;
			1'b1: R=A;
		endcase

endmodule


module Adder16bits(A,B,OP,Cin,R,AF,CF,OF);
	input [15:0] A,B;
	input OP,Cin;
	output [15:0] R;
	output wire AF,CF,OF;
	
	wire C0,C1,C2,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16;
	wire [15:0] opB;
	
	assign AF=C4,
			 CF=C16,
			 OF=(C15^C16);
	
	assign opB[0]=B[0]^OP,opB[1]=B[1]^OP,
			 opB[2]=B[2]^OP,opB[3]=B[3]^OP, 
			 opB[4]=B[4]^OP,opB[5]=B[5]^OP,
			 opB[6]=B[6]^OP,opB[7]=B[7]^OP,
			 opB[8]=B[8]^OP,opB[9]=B[9]^OP, 
			 opB[10]=B[10]^OP,opB[11]=B[11]^OP, 
			 opB[12]=B[12]^OP,opB[13]=B[13]^OP,
			 opB[14]=B[14]^OP,opB[15]=B[15]^OP; 
	
	assign C0=(Cin^OP);
	
	
	FullAdder	AD0 (A[0],opB[0],C0,R[0],C1);
	FullAdder	AD1 (A[1],opB[1],C1,R[1],C2);
	FullAdder	AD2 (A[2],opB[2],C2,R[2],C3);
	FullAdder	AD3 (A[3],opB[3],C3,R[3],C4);
	FullAdder	AD4 (A[4],opB[4],C4,R[4],C5);
	FullAdder	AD5 (A[5],opB[5],C5,R[5],C6); 
	FullAdder	AD6 (A[6],opB[6],C6,R[6],C7);
	FullAdder	AD7 (A[7],opB[7],C7,R[7],C8);
	FullAdder	AD8 (A[8],opB[8],C8,R[8],C9);
	FullAdder	AD9 (A[9],opB[9],C9,R[9],C10);
	FullAdder	AD10 (A[10],opB[10],C10,R[10],C11);
	FullAdder	AD11 (A[11],opB[11],C11,R[11],C12);
	FullAdder	AD12 (A[12],opB[12],C12,R[12],C13);
	FullAdder	AD13 (A[13],opB[13],C13,R[13],C14);
	FullAdder	AD14 (A[14],opB[14],C14,R[14],C15);
	FullAdder	AD15 (A[15],opB[15],C15,R[15],C16);				
							
endmodule 


//intrucciones de op
// op=00 => sin ajuste
// op=01 => sin ajuste
// op=10 => Ajuste Ascii (AAA o AAS)
// op=11 => Ajuste Decimal (DAA o DAS)

module AjustBasicModule(Ain,Bin,op,CFin,AFin,A,B,CF,AF);
	input [15:0] Ain,Bin;
	input [1:0] op;
	input AFin,CFin;
	output wire [15:0] A,B;
	output wire CF,AF;
	
	wire MA,MD;
	assign MA=(AFin|(Ain[3]&(Ain[2]|Ain[1])));
	assign MD=(CFin|(Ain[7]&(Ain[6]|Ain[5])));	
		
//Modulo de memoria
	wire [2:0] Dir;
	assign Dir={op[0],MD,MA};
   wire [15:0] Sal;
	RomDatosAjustBasic Rom(Dir,Sal);

//Salida
	Mux2a1de16bits MuxB(Bin,Sal,op[1],B);
	assign A=Ain;
	assign AF=op[1]&MA;
	assign CF=op[1]&((~op[0]&AF)|(op[0]&MD));
	
endmodule


//intrucciones de op
// op=000 => ADD
// op=001 => OR
// op=010 => ADC
// op=011 => SBB
// op=100 => AND
// op=101 => SUB
// op=110 => XOR
// op=111 => CMP

module ALU1module(opA,opB,Cin,op,R,CFA,AFA,OFA);
	input [15:0] opA,opB;
	input Cin;
	input [2:0] op;
	output wire [15:0] R;
	output wire CFA,AFA,OFA;
	
//modulos de operacion
	wire [15:0] RAND,ROR,RXOR,RSUM;
	wire CinAdder,AF,CF,OF;
	assign CinAdder=(Cin&op[1]&~op[2]);
	ANDmodule AND(opA,opB,RAND);
	ORmodule OR(opA,opB,ROR);
	XORmodule XOR(opA,opB,RXOR);
	Adder16bits Adder(opA,opB,op[0],CinAdder,RSUM,AF,CF,OF);

//Deco de Salidas
	wire [1:0] opMux;
	wire FA,FS;
	DecoALU1module DecSal(op,opMux,FA,FS);
	
//Mux de salida de datos
	Mux4a1de16bits MuxRDatos(RAND,ROR,RXOR,RSUM,opMux,R);
	
//Asignacion de Banderas	
	assign CFA=(CF&FA)|(~CF&FS);
	assign AFA=(AF&FA)|(~AF&FS);
	assign OFA=OF&(FA|FS);
endmodule

//intrucciones de op
// op=000 => ROL
// op=001 => ROR
// op=010 => RCL
// op=011 => RCR
// op=100 => SHL
// op=101 => SHR
// op=110 => SAL
// op=111 => SAR

module ALU2module(opA,opB,V,Cin,op,R,CF,OF);
	input [15:0] opA;
	input [3:0] opB;
	input V,Cin;
	input [2:0] op;
	output wire [15:0] R;
	output wire CF,OF;
	
//modulos de operacion
	wire [15:0] RS,RR;
	wire CFS,CFR,OFS,OFR;
	ShiftBasicModule SHI(opA,opB,V,op[1:0],RS,CFS,OFS);
	RotateBasicModule ROT(opA,opB,Cin,V,op[1:0],RR,CFR,OFR);
	
//Mux de salida de datos
	Mux2a1de16bits MuxRDatos(RR,RS,op[2],R);
	assign CF=(CFS&op[2])|(CFR&~op[2]);
	assign OF=(OFS&op[2])|(OFR&~op[2]);	
		
endmodule

module ANDmodule(A,B,R);
	input [15:0] A,B;
	output [15:0] R;

	assign R=A&B;
	
endmodule

module Comple2d16bits(A,cmp,R);
	input [15:0] A;
	input cmp;
	output [15:0] R;

//redes
	wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14;
//modulos
	FullComple2 FC0(A[0],cmp,cmp,R[0],C0);
	FullComple2 FC1(A[1],C0,cmp,R[1],C1);
	FullComple2 FC2(A[2],C1,cmp,R[2],C2);
	FullComple2 FC3(A[3],C2,cmp,R[3],C3);
	FullComple2 FC4(A[4],C3,cmp,R[4],C4);
	FullComple2 FC5(A[5],C4,cmp,R[5],C5);
	FullComple2 FC6(A[6],C5,cmp,R[6],C6);
	FullComple2 FC7(A[7],C6,cmp,R[7],C7);
	FullComple2 FC8(A[8],C7,cmp,R[8],C8);
	FullComple2 FC9(A[9],C8,cmp,R[9],C9);
	FullComple2 FC10(A[10],C9,cmp,R[10],C10);
	FullComple2 FC11(A[11],C10,cmp,R[11],C11);
	FullComple2 FC12(A[12],C11,cmp,R[12],C12);
	FullComple2 FC13(A[13],C12,cmp,R[13],C13);
	FullComple2 FC14(A[14],C13,cmp,R[14],C14);
	FullComple2inc FC15(A[15],C14,cmp,R[15]);

endmodule

module Comple2d16bitsB(A,Cin,cmp,R,Co);
	input [15:0] A;
	input Cin,cmp;
	output wire [15:0] R;
	output wire Co;

//redes
	wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14;
//modulos
	FullComple2 FC0(A[0],Cin,cmp,R[0],C0);
	FullComple2 FC1(A[1],C0,cmp,R[1],C1);
	FullComple2 FC2(A[2],C1,cmp,R[2],C2);
	FullComple2 FC3(A[3],C2,cmp,R[3],C3);
	FullComple2 FC4(A[4],C3,cmp,R[4],C4);
	FullComple2 FC5(A[5],C4,cmp,R[5],C5);
	FullComple2 FC6(A[6],C5,cmp,R[6],C6);
	FullComple2 FC7(A[7],C6,cmp,R[7],C7);
	FullComple2 FC8(A[8],C7,cmp,R[8],C8);
	FullComple2 FC9(A[9],C8,cmp,R[9],C9);
	FullComple2 FC10(A[10],C9,cmp,R[10],C10);
	FullComple2 FC11(A[11],C10,cmp,R[11],C11);
	FullComple2 FC12(A[12],C11,cmp,R[12],C12);
	FullComple2 FC13(A[13],C12,cmp,R[13],C13);
	FullComple2 FC14(A[14],C13,cmp,R[14],C14);
	FullComple2 FC15(A[15],C14,cmp,R[15],Co);

endmodule


module Comple2d16bitsCin(A,Cin,cmp,R);
	input [15:0] A;
	input Cin,cmp;
	output [15:0] R;

//redes
	wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14;
//modulos
	FullComple2 FC0(A[0],Cin,cmp,R[0],C0);
	FullComple2 FC1(A[1],C0,cmp,R[1],C1);
	FullComple2 FC2(A[2],C1,cmp,R[2],C2);
	FullComple2 FC3(A[3],C2,cmp,R[3],C3);
	FullComple2 FC4(A[4],C3,cmp,R[4],C4);
	FullComple2 FC5(A[5],C4,cmp,R[5],C5);
	FullComple2 FC6(A[6],C5,cmp,R[6],C6);
	FullComple2 FC7(A[7],C6,cmp,R[7],C7);
	FullComple2 FC8(A[8],C7,cmp,R[8],C8);
	FullComple2 FC9(A[9],C8,cmp,R[9],C9);
	FullComple2 FC10(A[10],C9,cmp,R[10],C10);
	FullComple2 FC11(A[11],C10,cmp,R[11],C11);
	FullComple2 FC12(A[12],C11,cmp,R[12],C12);
	FullComple2 FC13(A[13],C12,cmp,R[13],C13);
	FullComple2 FC14(A[14],C13,cmp,R[14],C14);
	FullComple2inc FC15(A[15],C14,cmp,R[15]);

endmodule


module Comple2d32bits(A,Cin,cmp,R);
	input [31:0] A;
	input Cin,cmp;
	output [31:0] R;

//redes
	wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,
		  C16,C17,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,C30;
//modulos
	FullComple2 FC0(A[0],Cin,cmp,R[0],C0);
	FullComple2 FC1(A[1],C0,cmp,R[1],C1);
	FullComple2 FC2(A[2],C1,cmp,R[2],C2);
	FullComple2 FC3(A[3],C2,cmp,R[3],C3);
	FullComple2 FC4(A[4],C3,cmp,R[4],C4);
	FullComple2 FC5(A[5],C4,cmp,R[5],C5);
	FullComple2 FC6(A[6],C5,cmp,R[6],C6);
	FullComple2 FC7(A[7],C6,cmp,R[7],C7);
	FullComple2 FC8(A[8],C7,cmp,R[8],C8);
	FullComple2 FC9(A[9],C8,cmp,R[9],C9);
	FullComple2 FC10(A[10],C9,cmp,R[10],C10);
	FullComple2 FC11(A[11],C10,cmp,R[11],C11);
	FullComple2 FC12(A[12],C11,cmp,R[12],C12);
	FullComple2 FC13(A[13],C12,cmp,R[13],C13);
	FullComple2 FC14(A[14],C13,cmp,R[14],C14);
	FullComple2 FC15(A[15],C14,cmp,R[15],C15);
	FullComple2 FC16(A[16],C15,cmp,R[16],C16);
	FullComple2 FC17(A[17],C16,cmp,R[17],C17);
	FullComple2 FC18(A[18],C17,cmp,R[18],C18);
	FullComple2 FC19(A[19],C18,cmp,R[19],C19);
	FullComple2 FC20(A[20],C19,cmp,R[20],C20);
	FullComple2 FC21(A[21],C20,cmp,R[21],C21);
	FullComple2 FC22(A[22],C21,cmp,R[22],C22);
	FullComple2 FC23(A[23],C22,cmp,R[23],C23);
	FullComple2 FC24(A[24],C23,cmp,R[24],C24);
	FullComple2 FC25(A[25],C24,cmp,R[25],C25);
	FullComple2 FC26(A[26],C25,cmp,R[26],C26);
	FullComple2 FC27(A[27],C26,cmp,R[27],C27);
	FullComple2 FC28(A[28],C27,cmp,R[28],C28);
	FullComple2 FC29(A[29],C28,cmp,R[29],C29);
	FullComple2 FC30(A[30],C29,cmp,R[30],C30);
	FullComple2inc FC31(A[31],C30,cmp,R[31]);

endmodule

module DecoALU1module(op,opMux,FA,FS);
	input [2:0] op;
	output reg [1:0] opMux;
	output wire FA,FS;
	
	assign FA=(opMux[1]&opMux[0]&~op[0]);
	assign FS=(opMux[1]&opMux[0]&op[0]);
	
	always @(op)
		case (op)
			3'b000: opMux=2'b11;
			3'b001: opMux=2'b01;
			3'b010: opMux=2'b11;
			3'b011: opMux=2'b11;
			3'b100: opMux=2'b00;
			3'b101: opMux=2'b11;
			3'b110: opMux=2'b10;
			3'b111: opMux=2'b11;
		endcase

endmodule

module DetectorParidad(A,P);
	input [15:0] A;
	output wire P;
	
	assign P=~(^A[15:0]);


endmodule

module DetectorZero(A,Z);
	input [15:0] A;
	output wire Z;
	
	assign Z=~|A;


endmodule

module Divi16bits(A,B,Comp,R,Cout);
	input [16:0] A;
	input [15:0] B;
	input Comp;
	output wire [15:0] R;
	output wire Cout;

//redes
	wire C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15;
	
//modulos
	FullDivi FD0(A[0],B[0],Comp,Comp,R[0],C0);
	FullDivi FD1(A[1],B[1],Comp,C0,R[1],C1);
	FullDivi FD2(A[2],B[2],Comp,C1,R[2],C2);
	FullDivi FD3(A[3],B[3],Comp,C2,R[3],C3);
	FullDivi FD4(A[4],B[4],Comp,C3,R[4],C4);
	FullDivi FD5(A[5],B[5],Comp,C4,R[5],C5);
	FullDivi FD6(A[6],B[6],Comp,C5,R[6],C6);
	FullDivi FD7(A[7],B[7],Comp,C6,R[7],C7);
	FullDivi FD8(A[8],B[8],Comp,C7,R[8],C8);
	FullDivi FD9(A[9],B[9],Comp,C8,R[9],C9);
	FullDivi FD10(A[10],B[10],Comp,C9,R[10],C10);
	FullDivi FD11(A[11],B[11],Comp,C10,R[11],C11);
	FullDivi FD12(A[12],B[12],Comp,C11,R[12],C12);
	FullDivi FD13(A[13],B[13],Comp,C12,R[13],C13);
	FullDivi FD14(A[14],B[14],Comp,C13,R[14],C14);
	FullDivi FD15(A[15],B[15],Comp,C14,R[15],C15);
 
	assign Cout=((~Comp&A[16]&C15)|(Comp&(A[16]|C15)));
	
endmodule 


module Divi16x16bits(CLK,RST,ENA,D,A,B,R,R2,FIN);
	input CLK,RST,ENA;
	input [15:0] D,A,B;
	output wire [15:0] R,R2;
	output wire FIN;
	
//Maquina de Estados
	wire [3:0] PRE;
	FSMDivi MaqEstDivi(CLK,RST,ENA,FIN,PRE);
	
//Redes
	wire [15:0] R3,Ro,RE,opD;
	wire C,Co,A0,P0;
	
	assign P0=|PRE;
	
//Muxes de operandos
	Mux16a1de1bit MuxdeA0(A[15],A[14],A[13],A[12],A[11],A[10],A[9],A[8],
								 A[7],A[6],A[5],A[4],A[3],A[2],A[1],A[0],PRE,A0);
								 
	Mux16a1de1bit MuxdeC(1'b1,R[15],R[14],R[13],R[12],R[11],R[10],R[9],
								R[8],R[7],R[6],R[5],R[4],R[3],R[2],R[1],PRE,C);
								
	Mux2a1de16bits MuxdeA(D,RE,P0,opD);
	
//Modulo Divisor
	Divi16bits D15({opD[15:0],A0},B,C,Ro,Co);

//Registro de ETAPA
	Reg16bitsEnaDown RegDeRE(CLK,RST,ENA|P0,Ro,RE);
	
//Registro de salida
	RegRotate16bitsEnaDown RegDeC(CLK,RST,ENA|P0,PRE,Co,R);
	
//Salida de Residuo
	SemiAdder16bits Sum(RE,B,R3);
	Mux2a1de16bits MuxResiduo(R3,RE,R[0],R2);


endmodule


module FSMDivi(CLK,RST,ENA,FIN,PRE);
	input CLK,RST,ENA;
	output [3:0] PRE;
	output wire FIN;
	
	//Registros de estado
	reg [3:0] PRE,FUT;
	parameter T0=4'b0000,T1=4'b0001,T2=4'b0010,T3=4'b0011,
				 T4=4'b0100,T5=4'b0101,T6=4'b0110,T7=4'b0111,
				 T8=4'b1000,T9=4'b1001,T10=4'b1010,T11=4'b1011,
				 T12=4'b1100,T13=4'b1101,T14=4'b1110,T15=4'b1111;

//Cambio de estado
	always @(negedge CLK or posedge RST)
		if (RST)
			PRE=T0;
		else 
			PRE=FUT;

//Seleccion de Siguiente estado			
	always @(PRE or ENA)
		case (PRE)
			T0: if (ENA)
					FUT=T1;
				 else
					FUT=T0;
			T1: FUT=T2;
			T2: FUT=T3;
			T3: FUT=T4;
			T4: FUT=T5;
			T5: FUT=T6;
			T6: FUT=T7;
			T7: FUT=T8;
			T8: FUT=T9;
			T9: FUT=T10;
			T10: FUT=T11;
			T11: FUT=T12;
			T12: FUT=T13;
			T13: FUT=T14;
			T14: FUT=T15;
			T15: FUT=T0;
		endcase

//Asignaciones de salida
	assign FIN=(~PRE[3]&~PRE[2]&~PRE[1]&~PRE[0]); //1111 = 0  0000 = 1

endmodule

module FullAdder(A,B,Cin,R,Cout);
	input A,B,Cin;
	output wire R,Cout;
	wire R1,O1,O2;
	
	assign R1=A^B;
	assign O1=A&B;
	assign R=R1^Cin;
	assign O2=R1&Cin;
	assign Cout=O1|O2;
	
endmodule 

module FullComple2(A,Cin,cmp,R,Cout);
	input A,Cin,cmp;
	output wire R,Cout;
	
	wire opA;
	assign opA=A^cmp;
	
	assign R=opA^Cin;
	assign Cout=opA&Cin;
endmodule

module FullComple2inc(A,Cin,cmp,R);
	input A,Cin,cmp;
	output wire R;
	
	wire opA;
	assign opA=A^cmp;
	
	assign R=opA^Cin;
endmodule

module FullDivi(A,B,Comp,Cin,R,Cout);
	input A,B,Comp,Cin;
	output wire R,Cout;
	
	wire opB;
	assign opB=B^Comp;
	
	FullAdder FA(A,opB,Cin,R,Cout);
endmodule


module Multi(A,B,R);
	input [15:0] A,B;
	output wire [31:0] R;
	
	assign R=A*B;

endmodule

module Mux2a1de8bits(A0,A1,OP,R);
	input [7:0] A0,A1;
	input OP;
	output reg [7:0] R;
	
	always @(A0 or A1 or OP)
		case (OP)
			1'b0: R=A0;
			1'b1: R=A1;
		endcase

endmodule

module Mux2a1de16bits(A0,A1,OP,R);
	input [15:0] A0,A1;
	input OP;
	output reg [15:0] R;
	
	always @(A0 or A1 or OP)
		case (OP)
			1'b0: R=A0;
			1'b1: R=A1;
		endcase

endmodule

module Mux4a1de1bit(A0,A1,A2,A3,OP,R);
	input A0,A1,A2,A3;
	input [1:0] OP;
	output reg R;
	
	always @(A0 or A1 or A2 or A3 or OP)
		case (OP)
			2'b00: R=A0;
			2'b01: R=A1;
			2'b10: R=A2;
			2'b11: R=A3;
		endcase

endmodule

module Mux4a1de16bits(A0,A1,A2,A3,OP,R);
	input [15:0] A0,A1,A2,A3;
	input [1:0] OP;
	output reg [15:0] R;
	
	always @(A0 or A1 or A2 or A3 or OP)
		case (OP)
			2'b00: R=A0;
			2'b01: R=A1;
			2'b10: R=A2;
			2'b11: R=A3;
		endcase

endmodule

module Mux8a1de1bit(A0,A1,A2,A3,A4,A5,A6,A7,OP,R);
	input A0,A1,A2,A3,A4,A5,A6,A7;
	input [2:0] OP;
	output reg R;
	
	always @(A0 or A1 or A2 or A3 or A4 or A5 or A6 or A7 or OP)
		case (OP)
			3'b000: R=A0;
			3'b001: R=A1;
			3'b010: R=A2;
			3'b011: R=A3;
			3'b100: R=A4;
			3'b101: R=A5;
			3'b110: R=A6;
			3'b111: R=A7;
		endcase

endmodule


module Mux16a1de1bit(A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15,op,R);
	input A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15;
	input [3:0] op;
	output reg R;
	
	always @ (A0 or A1 or A2 or A3 or A4 or A5 or A6 or A7 or A8
			or A9 or A10 or A11 or A12 or A13 or A14 or A15 or op)
		case (op)
			4'b0000: R=A0;
			4'b0001: R=A1;
			4'b0010: R=A2;
			4'b0011: R=A3;
			4'b0100: R=A4;
			4'b0101: R=A5;
			4'b0110: R=A6;
			4'b0111: R=A7;
			4'b1000: R=A8;
			4'b1001: R=A9;
			4'b1010: R=A10;
			4'b1011: R=A11;
			4'b1100: R=A12;
			4'b1101: R=A13;
			4'b1110: R=A14;
			4'b1111: R=A15;
		endcase
		
endmodule 

module MuxShiftLeftRota(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={A[14:0],A[15]};
			4'b0010: R={A[13:0],A[15:14]};
			4'b0011: R={A[12:0],A[15:13]};
			4'b0100: R={A[11:0],A[15:12]};
			4'b0101: R={A[10:0],A[15:11]};
			4'b0110: R={A[9:0],A[15:10]};
			4'b0111: R={A[8:0],A[15:9]};
			4'b1000: R={A[7:0],A[15:8]};
			4'b1001: R={A[6:0],A[15:7]};
			4'b1010: R={A[5:0],A[15:6]};
			4'b1011: R={A[4:0],A[15:5]};
			4'b1100: R={A[3:0],A[15:4]};
			4'b1101: R={A[2:0],A[15:3]};
			4'b1110: R={A[1:0],A[15:2]};
			4'b1111: R={A[0],A[15:1]};
		endcase
		
endmodule 


module MuxShiftLeftRotaWC(A,Cin,OP,R);
	input Cin;
	input [15:0] A;
	input [3:0] OP;
	output reg [16:0] R;
	
	always @ (A or Cin or OP)
		case (OP)
			4'b0000: R={Cin,A[15:0]};
			4'b0001: R={A[15:0],Cin};
			4'b0010: R={A[14:0],Cin,A[15]};
			4'b0011: R={A[13:0],Cin,A[15:14]};
			4'b0100: R={A[12:0],Cin,A[15:13]};
			4'b0101: R={A[11:0],Cin,A[15:12]};
			4'b0110: R={A[10:0],Cin,A[15:11]}; 
			4'b0111: R={A[9:0],Cin,A[15:10]};
			4'b1000: R={A[8:0],Cin,A[15:9]};
			4'b1001: R={A[7:0],Cin,A[15:8]};
			4'b1010: R={A[6:0],Cin,A[15:7]};
			4'b1011: R={A[5:0],Cin,A[15:6]};
			4'b1100: R={A[4:0],Cin,A[15:5]};
			4'b1101: R={A[3:0],Cin,A[15:4]};
			4'b1110: R={A[2:0],Cin,A[15:3]};
			4'b1111: R={A[1:0],Cin,A[15:2]};
		endcase
		
endmodule 

module MuxShiftLeftSimple(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={A[14:0],1'b0};
			4'b0010: R={A[13:0],2'b0};
			4'b0011: R={A[12:0],3'b0};
			4'b0100: R={A[11:0],4'b0};
			4'b0101: R={A[10:0],5'b0};
			4'b0110: R={A[9:0],6'b0};
			4'b0111: R={A[8:0],7'b0};
			4'b1000: R={A[7:0],8'b0};
			4'b1001: R={A[6:0],9'b0};
			4'b1010: R={A[5:0],10'b0};
			4'b1011: R={A[4:0],11'b0};
			4'b1100: R={A[3:0],12'b0};
			4'b1101: R={A[2:0],13'b0};
			4'b1110: R={A[1:0],14'b0};
			4'b1111: R={A[0],15'b0};
		endcase
		
endmodule 

module MuxShiftRightRota(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={A[0],A[15:1]};
			4'b0010: R={A[1:0],A[15:2]};
			4'b0011: R={A[2:0],A[15:3]};
			4'b0100: R={A[3:0],A[15:4]};
			4'b0101: R={A[4:0],A[15:5]};
			4'b0110: R={A[5:0],A[15:6]};
			4'b0111: R={A[6:0],A[15:7]};
			4'b1000: R={A[7:0],A[15:8]};
			4'b1001: R={A[8:0],A[15:9]};
			4'b1010: R={A[9:0],A[15:10]};
			4'b1011: R={A[10:0],A[15:11]};
			4'b1100: R={A[11:0],A[15:12]};
			4'b1101: R={A[12:0],A[15:13]};
			4'b1110: R={A[13:0],A[15:14]};
			4'b1111: R={A[14:0],A[15]};
		endcase
		
endmodule 


module MuxShiftRightRotaWC(A,Cin,OP,R);
	input Cin;
	input [15:0] A;
	input [3:0] OP;
	output reg [16:0] R;
	
	always @ (A or Cin or OP)
		case (OP)
			4'b0000: R={A[15:0],Cin};
			4'b0001: R={Cin,A[15:0]};
			4'b0010: R={A[0],Cin,A[15:1]};
			4'b0011: R={A[1:0],Cin,A[15:2]};
			4'b0100: R={A[2:0],Cin,A[15:3]};
			4'b0101: R={A[3:0],Cin,A[15:4]};
			4'b0110: R={A[4:0],Cin,A[15:5]};
			4'b0111: R={A[5:0],Cin,A[15:6]};
			4'b1000: R={A[6:0],Cin,A[15:7]};
			4'b1001: R={A[7:0],Cin,A[15:8]};
			4'b1010: R={A[8:0],Cin,A[15:9]};
			4'b1011: R={A[9:0],Cin,A[15:10]};
			4'b1100: R={A[10:0],Cin,A[15:11]};
			4'b1101: R={A[11:0],Cin,A[15:12]};
			4'b1110: R={A[12:0],Cin,A[15:13]};
			4'b1111: R={A[13:0],Cin,A[15:14]};
		endcase
		
endmodule 

module MuxShiftRightSimple(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={1'b0,A[15:1]};
			4'b0010: R={2'b0,A[15:2]};
			4'b0011: R={3'b0,A[15:3]};
			4'b0100: R={4'b0,A[15:4]};
			4'b0101: R={5'b0,A[15:5]};
			4'b0110: R={6'b0,A[15:6]};
			4'b0111: R={7'b0,A[15:7]};
			4'b1000: R={8'b0,A[15:8]};
			4'b1001: R={9'b0,A[15:9]};
			4'b1010: R={10'b0,A[15:10]};
			4'b1011: R={11'b0,A[15:11]};
			4'b1100: R={12'b0,A[15:12]};
			4'b1101: R={13'b0,A[15:13]};
			4'b1110: R={14'b0,A[15:14]};
			4'b1111: R={15'b0,A[15]};
		endcase
		
endmodule 


module MuxShiftRightSimpleArit(A,OP,R);
	input [15:0] A;
	input [3:0] OP;
	output reg [15:0] R;
	
	always @ (A or OP)
		case (OP)
			4'b0000: R=A[15:0];
			4'b0001: R={A[15],A[15:1]};
			4'b0010: R={A[15],A[15],A[15:2]};
			4'b0011: R={A[15],A[15],A[15],A[15:3]};
			4'b0100: R={A[15],A[15],A[15],A[15],A[15:4]};
			4'b0101: R={A[15],A[15],A[15],A[15],A[15],A[15:5]};
			4'b0110: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15:6]};
			4'b0111: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:7]};
			4'b1000: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:8]};
			4'b1001: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:9]};
			4'b1010: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:10]};
			4'b1011: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:11]};
			4'b1100: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:12]};
			4'b1101: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:13]};
			4'b1110: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:14]};
			4'b1111: R={A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15]};
		endcase
		
endmodule 


module ORmodule(A,B,R);
	input [15:0] A,B;
	output [15:0] R;

	assign R=A|B;
	
endmodule

module Reg1bitEnaDown(CLK,RST,ENA,D,Q);
	input CLK,RST,ENA;
	input D;
	output reg Q;

	always @(negedge CLK or posedge RST)
		if (RST)
			Q=1'b0;
		else if (ENA)
			Q=D;
		else
			Q=Q;

endmodule


module Reg1bitEnaSetDown(CLK,RST,ENA,SET,D,Q);
	input CLK,RST,ENA,SET;
	input D;
	output reg Q;

	always @(negedge CLK or posedge RST)
		if (RST)
			Q=1'b0;
		else if (SET)
			Q=1'b1;
		else if (ENA)
			Q=D;
		else
			Q=Q;

endmodule

module Reg1bitEnaSetTogDown(CLK,RST,ENA,SET,TOG,D,Q);
	input CLK,RST,ENA,TOG,SET;
	input D;
	output reg Q;

	always @(negedge CLK or posedge RST)
		if (RST)
			Q=1'b0;
		else if (SET)
			Q=1'b1;
		else if (TOG)
			Q=~Q;
		else if (ENA)
			Q=D;
		else
			Q=Q;

endmodule

module Reg16bitsEnaDown(CLK,RST,ENA,D,Q);
	input CLK,RST,ENA;
	input [15:0] D;
	output reg [15:0] Q;

	always @(negedge CLK or posedge RST)
		if (RST)
			Q=16'h0000;
		else if (ENA)
			Q=D;
		else
			Q=Q;

endmodule


module RegIfEnaSetDown(CLK,RST,RSET,ENA,SET,D,Q);
	input CLK,RST,RSET,ENA,SET;
	input D;
	output reg Q;

	always @(negedge CLK or posedge RST)
		if (RST)
			Q=1'b1;
		else if (RSET)
			Q=1'b0;
		else if (SET)
			Q=1'b1;
		else if (ENA)
			Q=D;
		else
			Q=Q;

endmodule

module RegRotate16bitsEnaDown(CLK,RST,ENA,SEL,D,Q);
	input CLK,RST,ENA;
	input D;
	input [3:0] SEL;
	output wire [15:0] Q;
	
	wire [15:0] WR;
	
	RomRegRotate16bits RomSel(SEL,WR);
	
	Reg1bitEnaDown Q0(CLK,RST,ENA&WR[0],D,Q[15]);
	Reg1bitEnaDown Q1(CLK,RST,ENA&WR[1],D,Q[14]);
	Reg1bitEnaDown Q2(CLK,RST,ENA&WR[2],D,Q[13]);
	Reg1bitEnaDown Q3(CLK,RST,ENA&WR[3],D,Q[12]);
	Reg1bitEnaDown Q4(CLK,RST,ENA&WR[4],D,Q[11]);
	Reg1bitEnaDown Q5(CLK,RST,ENA&WR[5],D,Q[10]);
	Reg1bitEnaDown Q6(CLK,RST,ENA&WR[6],D,Q[9]);
	Reg1bitEnaDown Q7(CLK,RST,ENA&WR[7],D,Q[8]);
	Reg1bitEnaDown Q8(CLK,RST,ENA&WR[8],D,Q[7]);
	Reg1bitEnaDown Q9(CLK,RST,ENA&WR[9],D,Q[6]);
	Reg1bitEnaDown Q10(CLK,RST,ENA&WR[10],D,Q[5]);
	Reg1bitEnaDown Q11(CLK,RST,ENA&WR[11],D,Q[4]);
	Reg1bitEnaDown Q12(CLK,RST,ENA&WR[12],D,Q[3]);
	Reg1bitEnaDown Q13(CLK,RST,ENA&WR[13],D,Q[2]);
	Reg1bitEnaDown Q14(CLK,RST,ENA&WR[14],D,Q[1]);
	Reg1bitEnaDown Q15(CLK,RST,ENA&WR[15],D,Q[0]);
			
endmodule

module RomDatosAjustBasic(Dir,Sal);
	input [2:0] Dir;
	output reg [15:0] Sal;
	
	always @(Dir)
		case (Dir)
			3'b000: Sal=16'b0000;
			3'b001: Sal=16'h0106;
			3'b010: Sal=16'h0000;
			3'b011: Sal=16'h0106;
			3'b100: Sal=16'b0000;
			3'b101: Sal=16'h0006;
			3'b110: Sal=16'h0060;
			3'b111: Sal=16'h0066;

		endcase

endmodule

module RomDecComp(op,A15,A7,B15,B7,D15,CA,c2inA,c2inB,c2out);	
	input [3:0] op;
	input A15,A7,B15,B7,D15;
	output wire CA,c2inA,c2inB,c2out;
	
	wire I,Mu,Di,N8,N16,MD,NI;
	assign I=op[1];
	assign Mu=~op[3]&~op[2];
	assign Di=~op[3]&op[2];
	assign N8=~op[0];
	assign N16=op[0];
	assign MD=~op[3];
	assign NI=op[3]&~op[2];
	
	assign c2inA=(I&((Mu&((A15&N16)|(A7&N8)))|(Di&((D15&N16)|(A15&N8)))))|NI;
	
	assign c2inB=I&(MD)&
						((B15&N16)|(B7&N8));
	
	assign CA=(MD&(I&((Mu&((A15&N16)|(A7&N8)))|(Di&((D15&N16)|(A15&N8))))))|(NI&op[0]);
	
	assign c2out=MD&(c2inA^c2inB);
	
endmodule


module RomopFL(opFL,RSTCF,RSTDF,RSTIF,SETCF,SETDF,SETIF,TOGCF);
	input [2:0] opFL;
	output wire RSTCF,RSTDF,RSTIF,SETCF,SETDF,SETIF,TOGCF;
	
	reg [6:0] D;
	assign {RSTCF,RSTDF,RSTIF,SETCF,SETDF,SETIF,TOGCF}=D;
	
	always @(opFL)
		case (opFL)
			3'b000: D=7'b0000000;
			3'b001: D=7'b1000000;
			3'b010: D=7'b0000001;
			3'b011: D=7'b0001000;
			3'b100: D=7'b0100000;
			3'b101: D=7'b0000100;
			3'b110: D=7'b0010000;
			3'b111: D=7'b0000010;
		endcase

endmodule

module RomRegRotate16bits(SEL,WR);
	input [3:0] SEL;
	output reg [15:0] WR;

	always @(SEL)
		case (SEL)
			4'b0000: WR={4'b0000,4'b0000,4'b0000,4'b0001};
			4'b0001: WR={4'b0000,4'b0000,4'b0000,4'b0010};
			4'b0010: WR={4'b0000,4'b0000,4'b0000,4'b0100};
			4'b0011: WR={4'b0000,4'b0000,4'b0000,4'b1000};
			
			4'b0100: WR={4'b0000,4'b0000,4'b0001,4'b0000};
			4'b0101: WR={4'b0000,4'b0000,4'b0010,4'b0000};
			4'b0110: WR={4'b0000,4'b0000,4'b0100,4'b0000};
			4'b0111: WR={4'b0000,4'b0000,4'b1000,4'b0000};
			
			4'b1000: WR={4'b0000,4'b0001,4'b0000,4'b0000};
			4'b1001: WR={4'b0000,4'b0010,4'b0000,4'b0000};
			4'b1010: WR={4'b0000,4'b0100,4'b0000,4'b0000};
			4'b1011: WR={4'b0000,4'b1000,4'b0000,4'b0000};
			
			4'b1100: WR={4'b0001,4'b0000,4'b0000,4'b0000};
			4'b1101: WR={4'b0010,4'b0000,4'b0000,4'b0000};
			4'b1110: WR={4'b0100,4'b0000,4'b0000,4'b0000};
			4'b1111: WR={4'b1000,4'b0000,4'b0000,4'b0000};
	endcase
	
endmodule


//intrucciones de op
// op=00 => ROL
// op=01 => ROR
// op=10 => RCL
// op=11 => RCR

module RotateBasicModule(A,B,Cin,Simp,op,R,CF,OF);
	input [15:0] A;
	input [3:0] B;
	input [1:0] op;
	input Cin,Simp;
	output wire [15:0] R;
	output wire CF,OF;
	
	wire [15:0] RRCL,RRCR,RROL,RROR;
	wire CRCR,CRCL;

//red de operacion
	reg [3:0] Des;
	always @(B or Simp)
		if (Simp)
			Des=4'b0001;
		else
			Des=B;
			
//modulos de corrimiento
	MuxShiftRightRotaWC RotacionRCR(A,Cin,Des,{RRCR[15:0],CRCR});
	MuxShiftLeftRotaWC RotacionRCL(A,Cin,Des,{CRCL,RRCL[15:0]});
	MuxShiftLeftRota RotacionROL(A,Des,RROL);
	MuxShiftRightRota RotacionROR(A,Des,RROR);	
	
//Mux de salida
	Mux4a1de16bits Mux(RROL,RROR,RRCL,RRCR,op,R);
	
	Mux4a1de1bit MuxC(R[15],R[0],CRCL,CRCR,op,CF);

//carry y overflow
	assign OF=(A[15]^R[15]);
	
endmodule

module SemiAdder8bits(A,B,R);
	input [7:0] A,B;
	output [7:0] R;
	
	wire C0,C1,C2,C4,C5,C6;

	SemiAdderIni	AD0 (A[0],B[0],R[0],C0);
	FullAdder	AD1 (A[1],B[1],C0,R[1],C1);
	FullAdder	AD2 (A[2],B[2],C1,R[2],C2);
	FullAdder	AD3 (A[3],B[3],C2,R[3],C3);
	FullAdder	AD4 (A[4],B[4],C3,R[4],C4);
	FullAdder	AD5 (A[5],B[5],C4,R[5],C5); 
	FullAdder	AD6 (A[6],B[6],C5,R[6],C6);
	SemiAdderFin	AD7 (A[7],B[7],C6,R[7]);
							
endmodule 

module SemiAdder16bits(A,B,R);
	input [15:0] A,B;
	output [15:0] R;
	
	wire C0,C1,C2,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14;

	SemiAdderIni	AD0 (A[0],B[0],R[0],C0);
	FullAdder	AD1 (A[1],B[1],C0,R[1],C1);
	FullAdder	AD2 (A[2],B[2],C1,R[2],C2);
	FullAdder	AD3 (A[3],B[3],C2,R[3],C3);
	FullAdder	AD4 (A[4],B[4],C3,R[4],C4);
	FullAdder	AD5 (A[5],B[5],C4,R[5],C5); 
	FullAdder	AD6 (A[6],B[6],C5,R[6],C6);
	FullAdder	AD7 (A[7],B[7],C6,R[7],C7);
	FullAdder	AD8 (A[8],B[8],C7,R[8],C8);
	FullAdder	AD9 (A[9],B[9],C8,R[9],C9);
	FullAdder	AD10 (A[10],B[10],C9,R[10],C10);
	FullAdder	AD11 (A[11],B[11],C10,R[11],C11);
	FullAdder	AD12 (A[12],B[12],C11,R[12],C12);
	FullAdder	AD13 (A[13],B[13],C12,R[13],C13);
	FullAdder	AD14 (A[14],B[14],C13,R[14],C14);
	SemiAdderFin	AD15 (A[15],B[15],C14,R[15]);
							
endmodule 

module SemiAdderFin(A,B,Cin,R);
	input A,B,Cin;
	output wire R;
	wire R1;
	
	assign R1=A^B;
	assign R=R1^Cin;
	
endmodule 


module SemiAdderIni(A,B,R,Cout);
	input A,B;
	output wire R,Cout;
	
	assign R=A^B;
	assign Cout=A&B;
	
endmodule 

//intrucciones de op
// op=00 => SHL
// op=01 => SHR
// op=10 => SAL
// op=11 => SAR

module ShiftBasicModule(A,B,Simp,op,R,CF,OF);
	input [15:0] A;
	input [3:0] B;//le digo cuanto desplazo
	input [1:0] op;
	input Simp;//se desplaza solo una unidad sin importar B
	output wire [15:0] R;
	output wire CF,OF;
	
	wire [15:0] RSHL,RSHR,RSAR;
	wire CFRight,CFLeft;

//red de operacion
	reg [3:0] Des;
	always @(B or Simp)
		if (Simp)
			Des=4'b0001;
		else
			Des=B;
			
//modulos de corrimiento
	MuxShiftRightSimple CorrimientoRS(A,Des,RSHR);
	MuxShiftLeftSimple CorrimientoLS(A,Des,RSHL);
	MuxShiftRightSimpleArit CorrimientoRSA(A,Des,RSAR);
	
//muxes de Carry
	Mux16a1de1bit CarryRight(A[14],A[13],A[12],A[11],A[10],A[9],A[8],A[7],A[6],A[5],A[4],A[3],A[2],A[1],A[0],1'b0,Des,CFRight);
	Mux16a1de1bit CarryLeft(A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15],1'b0,Des,CFLeft);

	
//Mux de salida
	Mux4a1de16bits Mux(RSHL,RSHR,RSHL,RSAR,op,R);

//carry y overflow
	assign CF=(CFRight&op[0])|(CFLeft&~op[0]);
	assign OF=(A[15]^R[15]);
	
endmodule


//intrucciones de op
// op=0000 => MUL	8BITS
// op=0001 => MUL  16BITS 
// op=0010 => IMUL 8BITS
// op=0011 => IMUL 16BITS
// op=0100 => DIV  8BITS
// op=0101 => DIV  16BITS
// op=0110 => IDIV 8BITS
// op=0111 => IDIV 16BITS
// op=1000 => NOT
// op=1001 => NEG
// op=1100 => CBW
// op=1101 => CWD
// op=1110 => AAM
// op=1111 => AAD

module UnidadProducto(CLK,RST,ENA,A,B,D,op,R1,R2,OF,CF,FIN);
	input CLK,RST,ENA;
	input [15:0] A,B,D;
	input [3:0] op;
	output wire [15:0] R1,R2;
	output wire OF,CF,FIN;

//Muxes de AAM y AAD de entrada
	wire [15:0] AAMD,AA;
	Mux2a1de8bits MuxAMAD(A[7:0],A[15:8],op[0],AAMD[7:0]);
	assign AAMD[15:8]=8'b0;
	Mux2a1de16bits MuxdeEntrada(A,AAMD,op[3]&op[2],AA);
	
//Complemento a 2
	wire CA,Co,c2inA,c2inB,c2out;
	wire [15:0] opA,opB,opD,DR;
	Comple2d32bits CompA2A({D,AA},CA,c2inA,{DR,opA});
	Comple2d16bits CompA2B(B,c2inB,opB);
	
	ACT16bits ActivadorD(DR,op[0],opD);
	
//Rom decodificador de complementos
	RomDecComp DecoComple(op,AA[15],AA[7],B[15],B[7],D[15],CA,c2inA,c2inB,c2out);	
	
//Modulos
	wire [15:0] RMUL,RDIV,RMUL2,REDIV;
	Divi16x16bits Divisor(CLK,RST,ENA,opD,opA,opB,RDIV,REDIV,FIN);
	Multi Multiplicador(opA,opB,{RMUL2,RMUL});
	
//Complementos a 2 de salida
	wire [15:0] opR1,opR2,C2R1,C2R2,opR;
	Mux2a1de16bits MuxR1(RMUL,RDIV,op[2],opR1);
	Mux2a1de16bits MuxR2(RMUL2,REDIV,op[2],opR2);
	
	Comple2d16bitsB CompA2R1(opR1,c2out,c2out,C2R1,Co);
	Comple2d16bitsCin CompA2R2(opR2,((Co&~op[2])|(c2out&op[2])),c2out,C2R2);
	
	Mux2a1de16bits AjustedeDIV(C2R1,{C2R2[7:0],C2R1[7:0]},(op[2]&~op[0]),opR);

//Seleccion de AAM y AAD e Conversiones a Word o DWord
	wire [15:0] opAAMDC;
	wire [7:0] opRAAD;
	SemiAdder8bits AdderdeAAM(RMUL[7:0],A[7:0],opRAAD);	
	Mux4a1de16bits MuxdeopAAMDC({A[7],A[7],A[7],A[7],A[7],A[7],A[7],A[7],A[7:0]},
										{A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15]},
										{RDIV[7:0],REDIV[7:0]},
										{8'b0,opRAAD},
										op[1:0],opAAMDC);
	
//Mux de Salida
	Mux4a1de16bits MuxdeR1(opR,opR,opA,opAAMDC,op[3:2],R1);
	assign R2=C2R2;

//Banderas
	assign OF=CF;
	assign CF=|RMUL2;
endmodule

module XORmodule(A,B,R);
	input [15:0] A,B;
	output [15:0] R;
	
	assign R=A^B;
endmodule

