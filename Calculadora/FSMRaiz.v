
module FSMRaiz(CLK,RST,OP,START,STOP,ALUDONE,ENARX,ENARY,ENARC,ENARZ,ENARD,MuxInOP,RaizOP,OP_Y,RAIZSTART,RaizDONE,ALURST);
    input CLK,RST,OP,START,STOP,ALUDONE;
    output  ENARX,ENARY,ENARC,ENARZ,ENARD;
    output [2:0] MuxInOP;
    output [1:0] RaizOP;
    output  OP_Y,RAIZSTART,RaizDONE,ALURST;

//VARS Y PARAMETERS

    reg [4:0] PRE,FUT;
    parameter T0=5'b00000,T1=5'b00001,T2=5'b00010,T3=5'b00011,T4=5'b00100,T5=5'b00101,T6=5'b00110,T7=5'b00111,
				  T8=5'b01000,T9=5'b01001,T10=5'b01010,T11=5'b01011,T12=5'b01100,T13=5'b01101,T14=5'b01110,T15=5'b01111,
              T16=5'b10000,T17=5'b10001,T18=5'b10010,T19=5'b10011,T20=5'b10100,T21=5'b10101,T22=5'b10110,T23=5'b10111,
              T24=5'b11000,T25=5'b11001,T26=5'b11010,T27=5'b11011,T28=5'b11100,T29=5'b11101,T30=5'b11110,T31=5'b11111; 

//TRANSICION DE ESTADOS

    always @(posedge CLK or posedge RST) 
        if(RST)
                PRE=T0;
        else
                PRE=FUT;
		 
//RED DEL ESTADO FUTURO

    always @(PRE or START or OP or ALUDONE or STOP) 
        case (PRE)
            T0: if (START & OP)   //SEGUIMOS SI START
                    FUT = T1;
                else
                    FUT = T0;
				T1: FUT=T2;     //ESCRIBIMOS WX/WY
            T2: FUT=T3;     //SELECCIONAMOS X
            T3: FUT=T4;     //DAMOS START
            T4: FUT=T5;     //SELECCIONAMOS Y
            T5: if (ALUDONE)  //ESPERAMOS A DONE
                    FUT = T6;
                else
                    FUT = T5;	  
					
            T6: FUT=T7;     //ESCRIBIMOS C Y SELECCONAMOS C
            T7: FUT=T8;     //DAMOS START
            T8: FUT=T9;     //SELECCIONAMOS Y
            T9: if (ALUDONE)  //ESPERAMOS A DONE
                    FUT=T10;
                else
                    FUT=T9;
					
            T10: FUT=T30;   //ESCRIBIMOS EN Z Y SELECCIONAMOS Z
            T11: FUT=T12;   //DAMOS START
				T12: FUT=T13;   //SELECCIONAMOS Z
            T13: if (ALUDONE)  //ESPERAMOS A DONE
                    FUT=T14;
                 else
                    FUT=T13;
              
            T14: FUT=T15;   //GUARDAMOS Z Y SELECCIONAMOS Z
            T15: FUT=T16;   //DAMOS START
            T16: if (ALUDONE)  //ESPEREMOS A DONE
                    FUT=T17;
					else 
                    FUT=T16;
            
            T17: FUT=T31;   //ESCRIBIMOS D Y SELECCIONAMOS D
            T18: FUT=T19;   // DAMOS START
            T19: FUT=T20;   //SELECCIONAMOS X
            T20: if (ALUDONE)  // ESPERAMOS A DONE
                    FUT=T21;
                 else
                    FUT=T20;	  
						  
            T21: FUT=T22;   //ESCRIBIMOS D
            T22: if (STOP)  //REVISION DE PARADA
                    FUT=T24;
                 else
                    FUT=T23;
            
            T23: FUT=T2;    //ESCRIBIMOS Y Y REGRESAMOS
            T24: FUT=T25;   //SELECCIONAMOS Z
				T25: FUT=T27;   //DAMOS START
            T26: FUT=T0;
            T27: FUT=T28;   //SLECCIONAMOS 0
            T28: if (ALUDONE)  //ESPERAMOS A DONE
                    FUT=T29;
                 else
                    FUT=T28;
            
            T29: FUT=T0;    //DAMOS DONE
            T30: FUT=T11;
            T31: FUT=T18;
				  
        endcase 
    

//DECO DE SALIDA

    //
    wire OP_Y,RaizDone;
    assign OP_Y = PRE[4] & ~PRE[3] & PRE[2] & PRE[1]; //1011
    assign RaizDONE = PRE[4] & PRE[3] & PRE[2] &  ~PRE[1] & PRE[0];
    //
	 reg  ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST;
    always @(PRE) 
        case (PRE)
            T0:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T1:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b1100000};
            T2:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
				T3:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T4:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T5:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T6:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0010000};
            T7:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T8:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T9:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
				T10:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0001000};
            T11:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T12:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T13:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T14:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0001000};
            T15:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T16:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
				T17:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000100};
            T18:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T19:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T20:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T21:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000100};
				T22:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T23:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0100001};
            T24:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T25:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000010};
            T26:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
				T27:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T28:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T29:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
            T30:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000001};
				default:{ENARX,ENARY,ENARC,ENARZ,ENARD,RAIZSTART,ALURST} = {7'b0000000};
        endcase
		      
    reg [2:0] MuxInOP;
    reg [1:0] RaizOP;
    always @(PRE) 
        case (PRE)
            T0:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T1:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T2:{MuxInOP,RaizOP} = {3'b001,2'b11};
            T3:{MuxInOP,RaizOP} = {3'b000,2'b11};
				T4:{MuxInOP,RaizOP} = {3'b010,2'b11};
            T5:{MuxInOP,RaizOP} = {3'b010,2'b11};
            T6:{MuxInOP,RaizOP} = {3'b011,2'b00};
            T7:{MuxInOP,RaizOP} = {3'b011,2'b00};
            T8:{MuxInOP,RaizOP} = {3'b010,2'b00};
            T9:{MuxInOP,RaizOP} = {3'b010,2'b00};
            T10:{MuxInOP,RaizOP} = {3'b100,2'b00};
            T11:{MuxInOP,RaizOP} = {3'b100,2'b11};
            T12:{MuxInOP,RaizOP} = {3'b110,2'b11};
				T13:{MuxInOP,RaizOP} = {3'b110,2'b11};
            T14:{MuxInOP,RaizOP} = {3'b100,2'b10};
            T15:{MuxInOP,RaizOP} = {3'b100,2'b10};
            T16:{MuxInOP,RaizOP} = {3'b100,2'b10};
            T17:{MuxInOP,RaizOP} = {3'b101,2'b10};
            T18:{MuxInOP,RaizOP} = {3'b101,2'b01};
            T19:{MuxInOP,RaizOP} = {3'b001,2'b01};
            T20:{MuxInOP,RaizOP} = {3'b000,2'b01};
            T21:{MuxInOP,RaizOP} = {3'b000,2'b01};
				T22:{MuxInOP,RaizOP} = {3'b000,2'b01};
            T23:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T24:{MuxInOP,RaizOP} = {3'b100,2'b00};
            T25:{MuxInOP,RaizOP} = {3'b100,2'b00};
            T26:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T27:{MuxInOP,RaizOP} = {3'b111,2'b00};
            T28:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T29:{MuxInOP,RaizOP} = {3'b000,2'b00};
            T30:{MuxInOP,RaizOP} = {3'b100,2'b11};
				T31:{MuxInOP,RaizOP} = {3'b101,2'b01};
				default:{MuxInOP,RaizOP} = {3'b000,2'b00};
			endcase
endmodule 