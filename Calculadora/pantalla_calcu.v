
module pantalla_calcu(clk,OP,reg_A,reg_B,estado,raiz,Sum_Res,Mult_Div,COUT,DONE,numeros1);
	input clk,COUT,DONE;
	input [39:0] reg_A,reg_B,Sum_Res,Mult_Div,raiz;
	input [1:0] estado;
	input [2:0] OP;
	output reg [39:0] numeros1;
	
	//SAlIDA DE SELECT PARA MEMORIA DE FONTS
	reg [39:0] Resultado,numeros;
	wire num,resul;
	
	always @(negedge clk) 
	begin
		if(estado[1] == 1'b1 && estado[0] == 1'b1 && OP[2] == 1'b0 && ((OP[1] == 1'b0 && OP[0] == 1'b0) || (OP[1] == 1'b0 && OP[0] == 1'b1)))//(COUT == 1'b0||DONE == 1'b0) 
			numeros = Sum_Res;
		else if(estado[1] == 1'b1 && estado[0] == 1'b1 &&(OP[2] == 1'b0 &&((OP[1] == 1'b1 && OP[0] == 1'b0) || (OP[1] == 1'b1 && OP[0] == 1'b1))))//MULTI
			numeros = Mult_Div;
		else if(estado[1] == 1'b1 && estado[0] == 1'b1 &&(OP[2] == 1'b1))//RAIZ
			numeros = raiz;
      else
			numeros = numeros;
	end
	
	always @(posedge clk) 
      if(DONE == 1'b1 &&(OP[2] == 1'b1))//muestra registro A
			Resultado = numeros;
		else	
			Resultado = Resultado;

	//assign num = |numeros;
	assign resul = |Resultado;
	
	always @(posedge clk) 
	begin
      if(estado[1] == 1'b0 && estado[0] == 1'b1 && (COUT == 1'b0||DONE == 1'b0))//muestra registro A
			numeros1 = reg_A;
      else if(estado[1] == 1'b1 && estado[0] == 1'b0)////muestra registro B
			numeros1 = reg_B;
      else if((OP[2] == 1'b0))//
			numeros1 = numeros;
		else if(resul == 1'b1 && (OP[2] == 1'b1))
			numeros1 = Resultado;
		else 
			numeros1 = numeros1;
	end
endmodule
