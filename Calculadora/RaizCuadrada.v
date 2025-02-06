
module RaizCuadrada(CLK,RST,START,OP,IN,OUT,COUT,DONE);
    input CLK,RST,START;
    input [2:0] OP;
    input [39:0] IN;
    output wire [39:0] OUT;
    output wire COUT,DONE;

//WIRE
    wire ALUSTART,RAIZSTART;
    wire [1:0] ALUOP;
    wire [39:0] ALUIN;
    wire [39:0] QBAJO;
    wire [39:0] OUT_Y;
	 wire [39:0] S;
	 wire [2:0] MuxInOP;
    wire [1:0] RaizOP;
    wire STOP,ALUDONE,RaizDONE;
    wire [39:0] QRX,QRY,QRC,QRZ,QRD;
    wire ENARX,ENARY,ENARC,ENARZ,ENARD,OP_Y,ALURST;

//WIRE DONE AND ALUSTART
    assign DONE = (RaizDONE & OP[2]) | (ALUDONE & ~OP[2]);
    assign ALUSTART = (RAIZSTART & OP[2]) | (START & ~OP[2]);

//MUX DE EMTRADA A REGISTROS Y
	 Mux2a1de40bits MuxEntradaRegY ({1'b0,IN[39:1]},QRZ,OP_Y,OUT_Y);

//REGISTROS
    Registro40bitsEna RX(CLK,RST,ENARX,IN,QRX);
    Registro40bitsEna RY(CLK,RST,ENARY,OUT_Y,QRY);
    Registro40bitsEna RC(CLK,RST,ENARC,QBAJO,QRC);
    Registro40bitsEna RZ(CLK,RST,ENARZ,OUT,QRZ);
    Registro40bitsEna RD(CLK,RST,ENARD,OUT,QRD);

//MUX DE DATOS A LA ALU
    Mux8a1de8bits MuxaALU8bits(IN,QRX,QRY,QRC,QRZ,QRD,40'd2,40'b0,MuxInOP,ALUIN);

//MUX DE OP
    Mux2a1de2bits Mop2bits (OP[1:0],RaizOP,OP[2],ALUOP);

//ALU
    ALU_chema ALU_chema(CLK,(RST |ALURST) ,ALUSTART,ALUOP,ALUIN,QBAJO,S,COUT,ALUDONE);

//MUX DE SALIDA
    Mux2a1de40bits MuxSalida40bits (S,QBAJO,ALUOP[1],OUT);

//CONDICION DE PARADA
    assign STOP = (&QRD) | (~|QRD) | (~|QRD[39:1] & QRD[0]);

//FSM RAIZ
    FSMRaiz FSMRaiz (CLK,RST,OP[2],START,STOP,ALUDONE,ENARX,ENARY,ENARC,ENARZ,ENARD,MuxInOP,RaizOP,OP_Y,RAIZSTART,RaizDONE,ALURST);

endmodule
