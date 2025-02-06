
// fsm_control maquinita(.clk(CLK),.rst(RST),.BM(bm),.pos_18_21(POS_actual[21:18]),.pos_24_25(POS_actual[25:24]),.estado(Estado),.OP(OP));//.START(START),

module fsm_control(clk,rst,BM,pos_17_21,pos_24_25,estado,OP);
   input clk,rst,BM; //Si un jugador presiona el boton del medio termina su turno y se regitra su marco
	input [1:0] pos_24_25;//0=24/1=25
	input [4:0] pos_17_21;//18=0/19=1/20=2/21=3
  	output reg [1:0] estado;//para enviar el estado actual del juego
	output reg [2:0] OP;
//	output reg START;
//pos_18_21 ==  18=0/19=1/20=2/21=3   pos_24_25 == 0=24/1=25
// estados de FSM
  	//parameter Color_J1=3'b00;
	//parameter Color_J2=3'b01;
	parameter RST=2'b00;
	parameter A=2'b01;
	parameter B=2'b10;
	parameter R=2'b11;
  	reg [1:0] actual_estado , sig_estado;
	wire a,b;


// registro del estado actual
  always @(posedge clk or posedge rst) 
	begin
      if(rst)
  			actual_estado = RST;
 		else
  			actual_estado = sig_estado;
	end
// siguiente stado
  always @(negedge clk)//negedge BM or actual_estado or tablero_lleno or celda_llena or ganador
 	begin
 		case(actual_estado)
 			RST: //00
   				sig_estado = A;// comienza a registrar en A
          
 			A:begin //01 = Turno de elegir numeros para A
              	if(rst==1'b1 || (pos_24_25[0] == 1'b1 && BM == 1'b1))//para recetear el juego
                	sig_estado = RST;
              	else if(BM == 1'b1 && ((pos_17_21[0] == 1)||(pos_17_21[1] == 1)||(pos_17_21[2] == 1)||(pos_17_21[3] == 1)||(pos_17_21[4] == 1)))
   					sig_estado = B; // Pasa al estado B para meter el numero a operar
  				else 
   					sig_estado = A;//sigue en el estado A para agragar mas numeros
            end
 			B:begin //01 = Turno de elegir numeros para B
				if(rst == 1'b1 || (pos_24_25[0] == 1'b1 && BM == 1'b1))//para recetear el juego
              	sig_estado = RST;
            else if(BM == 1'b1 && pos_24_25[1] == 1'b1)// presiona "="
              	sig_estado = R; // realiza la operacion
  				else 
   				sig_estado = B;//sigue en el estado A para agragar mas numeros
            end
 			R:begin // 11 = juego terminado por empate o ganador
  				if(rst==1'b1 || (pos_24_25[0] == 1'b1 && BM == 1'b1))
   					sig_estado = RST;// Es necesario resetear el juego para limpiar el tablero	
  				else
                 	sig_estado = R;
 			end 
 			default: sig_estado = RST;
        endcase
    end
	 
	always @(posedge clk)//negedge BM or actual_estado or tablero_lleno or celda_llena or ganador
 	begin
 		case(actual_estado)
 			RST: //00
   				estado = RST;// jugador 1 comienza
          
 			A:begin //01 = Turno de elegir numeros para A
              	if(rst==1'b1 || (pos_24_25[0] == 1'b1 && BM == 1'b1))//para recetear el juego
                	estado = RST;
              	else if(BM == 1'b1 && ((pos_17_21[0] == 1'b1)||(pos_17_21[1] == 1'b1)||(pos_17_21[2] == 1'b1)||(pos_17_21[3] == 1'b1)||(pos_17_21[4] == 1'b1)))
   					estado = B; // Pasa al estado B para meter el numero a operar
//					else if (num == 1'b1)
//   					estado = A;//sigue en el estado A para agragar mas numeros
					else
						estado = A;
           end

 			B:begin //01 = Turno de elegir numeros para A
				if(rst==1'b1 || (BM == 1'b1 && pos_24_25[0] == 1'b1))//para recetear el juego
              	estado = RST;
            else if(BM == 1'b1 && pos_24_25[1] == 1'b1)// presiona "="
              	estado = R; // realiza la operacion
  				else 
   				estado = B;//sigue en el estado B para agragar mas numeros
            end
 			R:begin // 11 = juego terminado por empate o ganador
  				if(rst==1'b1 || (BM == 1'b1 && pos_24_25[0] == 1'b1))
   					estado = RST;// Es necesario resetear el juego para limpiar el tablero	
  				else 
                 	estado = R;
 			end 
 			default: estado = RST;
        endcase
    end

//Para enviar a la salida el tipo de operacion
	always @(posedge clk or posedge rst) 
	begin
      if(rst)
  			OP = 3'b000;
      else if(BM == 1'b1 && pos_17_21[1] == 1'b1)//Multiplicacion
			OP = 3'b010;
      else if(BM == 1'b1 && pos_17_21[2] == 1'b1)//Division
			OP = 3'b011;
      else if(BM == 1'b1 && pos_17_21[3] == 1'b1)//Suma
			OP = 3'b000;
      else if(BM == 1'b1 && pos_17_21[4] == 1'b1)//Resta
			OP = 3'b001;
      else if(BM == 1'b1 && pos_17_21[0] == 1'b1)//Raiz
			OP = 3'b100;
		else
			OP = OP;
	end
endmodule
// ////pos_17_21 ==  17=0/18=1/19=2/20=3/21=4   pos_24_25 == 0=24/1=25

