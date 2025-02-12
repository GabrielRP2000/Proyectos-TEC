`timescale 1ns / 1ps

//intrucciones de op
// op=000000 => ADD
// op=000001 => OR
// op=000010 => ADC
// op=000011 => SBB
// op=000100 => AND
// op=000101 => SUB
// op=000110 => XOR
// op=000111 => CMP
// op=001000 => ROL
// op=001001 => ROR
// op=001010 => RCL
// op=001011 => RCR
// op=001100 => SHL
// op=001101 => SHR
// op=001110 => SAL
// op=001111 => SAR
// op=010000 => AAA
// op=010101 => AAS
// op=011000 => DAA
// op=011101 => DAS
// op=100000 => MUL	8BITS
// op=100001 => MUL  16BITS 
// op=100010 => IMUL 8BITS
// op=100011 => IMUL 16BITS
// op=100100 => DIV  8BITS
// op=100101 => DIV  16BITS
// op=100110 => IDIV 8BITS
// op=100111 => IDIV 16BITS
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
