
module Retraso_start_B(clk,rst,inB,listoB,estado,retraST,retraB);//inB,retraB
	input clk,rst;
	input [1:0] estado;
	input [39:0] inB;
	
	output wire retraST,listoB;
	output reg [39:0] retraB;

	reg [2:0] contador;
	reg bandera,bandera2;
	wire con;
//	reg [5:0] contador2;

//		#30 IN = 2;
//		#20 START=0;

	always @(negedge clk or posedge rst) 
		if (rst)
		begin
			bandera = 1'b0;
			bandera2 = 1'b1;
		end
		else if (contador == 3'b1)
			bandera = 1'b1;
		else if (contador == 3'b11)
			bandera2 = 1'b0;
		else
		begin
			bandera = bandera;
			bandera2 = bandera2;
		end


  	always @(posedge clk or posedge rst) 
		if (rst)
        	contador = 3'b0;
		else if (estado[1] == 1'b1 && estado[0] == 1'b1)
			contador = contador + 3'b1;
		else
			contador = 3'b0;

	assign con = |contador;
	assign retraST = (con)&&bandera2;


	always @(negedge clk or posedge rst) 
		if (rst) 
        	retraB = 40'b0;
		else if (bandera) 
			retraB = inB;//son 5 ciclos de retraso
		else
			retraB = 40'b0;

		assign listoB = |retraB;
endmodule

//always @(posedge clk or posedge rst) 
//		if (rst)
//		begin
//        	contador = 3'b0;
//			bandera = 1'b0;
//			bandera2 = 1'b0;
//		end
//		else if (Start) 
//			bandera = 1'b1;
//		else if (contador == 3'b1)
//			bandera2 = 1'b1;
//		else if (Start == 1'b0 && bandera == 1'b1) 
//		begin
//			contador = 3'b101;//son 5 ciclos de retraso
//			bandera = 1'b0;
//		end
//		else if (estado[1] == 1'b1 && estado[0] == 1'b1 && bandera2 == 1'b0)
//			contador = contador - 3'b1;
//		else
//		begin
//			bandera = bandera;
//			bandera2 = 1'b0;
//		end
