//////////////////////////////////////////////////////////////////////////////////
// Name: Gabriel Rodriguez Palacios, Jose Calvo Elizondo 
// Create Date: 12.09.2021
// Project Name: Semaforo con 2 estados
//////////////////////////////////////////////////////////////////////////////////

module BouncingButtom(CLK,RESET,BOT,BOTOUT);
	input CLK,RESET,BOT;
	output reg BOTOUT;

	wire CUENTADONE;
	reg SET;
	reg CUENTAENA;
	reg [19:0] CUENTA;
	
	always @(posedge CLK)
		if (SET)
			CUENTA=20'd1000000;//1000000
		else if (CUENTAENA)
			CUENTA=CUENTA-1'b1;
		else
			CUENTA=CUENTA;

	assign CUENTADONE = (CUENTA==20'd0);
	
////////////////////////////////////////MAQUINA DE ESTADOS DEBOUNCE BUTTON

//Registros de Estado

	reg [1:0] PRE,FUT;
	parameter T0=2'b00, T1=2'b01, T2=2'b10, T3=2'b11;

//Registro de Transicion de estado
	always @(negedge CLK or posedge RESET)
	if (RESET)
			PRE=T0;
	else
		PRE=FUT;

//Red del estado futuro
	always @(PRE or BOT or CUENTADONE)begin
	case (PRE)
		T0: if (BOT)
				FUT=T1;
			 else
				FUT=T0;
		T1: if (CUENTADONE)
				FUT=T2;
			 else
				FUT=T1;

		T2: if (BOT)
				FUT=T1;
			 else
				FUT=T3;

		T3: FUT=T0;

	endcase
	end
//Asignacion de Salidas
	always @(PRE) begin
	case (PRE)
		T0:begin
				SET = 1;

				CUENTAENA = 0;

				BOTOUT = 0;
			end

		T1:begin
				SET = 0;

				CUENTAENA = 1;

				BOTOUT = 0;
			end

		T2:begin
				SET = 1;

				CUENTAENA = 0;

				BOTOUT = 0;
			end

		T3:begin
				SET = 0;

				CUENTAENA = 0;

				BOTOUT = 1;
			end
	endcase
	end
endmodule
