
module Registro_Digitos_A(clock,reset,C,BM,pos_actual,estado,A);
   input clock,reset,BM,C;
	input [1:0] estado;
  	input wire [25:0] pos_actual; // Computer enable signals
  	output wire [39:0] A;//guarda los colores
	
	reg [3:0] a0,a1,a2,a3,a4,a5,a6,a7,a8,a9;
//	reg [3:0] c0,c1,c2,c3,c4,c5,c6,c7,c8,c9;
	reg [3:0] b0,b1,b2,b3,b4,b5,b6,b7,b8,b9;
	reg [3:0] contador;
//contador = encargado de avisar si ya se llenaron los 10 registros con info
//	reg [9:0] contador_desplaza;
//contador desplaza = cuenta si ya se paso toda la info para dejar libre a a11
	reg desplaza,desplaza_inv,bm,bandera;//para que comience a desplazar
	wire simbolos,full;
	
	assign simbolos = |pos_actual [25:16];
	assign full = contador [3] & contador[1];


//ver si se desplaza derecha o izquierda
	always @(*)
	begin
      if(reset == 1'b1 || (BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 &&(pos_actual[22] == 1'b1 || pos_actual[24] == 1'b1)))
			desplaza = 1'b0;
		else if(full == 1'b0 && BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 && simbolos == 1'b0)
			desplaza = 1'b1;
		else
			desplaza = 1'b0;
	end
	
	always @(*)
	begin
      if(reset == 1'b1 || (BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 &&(pos_actual[22] == 1'b1 || pos_actual[24] == 1'b1)))
			desplaza_inv = 1'b0;
		else if(BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 && (pos_actual[23] == 1'b1))
			desplaza_inv = 1'b1;
		else
			desplaza_inv = 1'b0;
	end
//contador
	always @(posedge clock or posedge reset)
	begin
      if(reset == 1'b1 || (BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 &&(pos_actual[22] == 1'b1 || pos_actual[24] == 1'b1)))
			contador = 4'b0;
		else if(full == 1'b0 && BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 && simbolos == 1'b0)
			contador = contador + 4'b1;
		else if(BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0 && (pos_actual[23] == 1'b1))
			contador = contador - 4'b1;
		else
			contador = contador;
	end

	
	always @(posedge clock or posedge reset)
	begin
      if((reset == 1'b1) || (C == 1'b1) ||((BM == 1'b1 && estado[0] == 1'b1 && estado[1] == 1'b0)&&(pos_actual[22] == 1'b1 || pos_actual[24] == 1'b1)))
		begin
			bandera = 1'b0;
			a0 = 4'b0;
			a1 = 4'b0;
			a2 = 4'b0;
			a3 = 4'b0;
			a4 = 4'b0;
			a5 = 4'b0;
			a6 = 4'b0;
			a7 = 4'b0;
			a8 = 4'b0;
			a9 = 4'b0;
			b0 = 4'b0;
			b1 = 4'b0;
			b2 = 4'b0;
			b3 = 4'b0;
			b4 = 4'b0;
			b5 = 4'b0;
			b6 = 4'b0;
			b7 = 4'b0;
			b8 = 4'b0;
			b9 = 4'b0;
			
//			A [39:36] = 4'b0;
//			A [35:32] = 4'b0;
//			A [31:28] = 4'b0;
//			A [27:24] = 4'b0;
//			A [23:20] = 4'b0;
//			A [19:16] = 4'b0;
//			A [15:12] = 4'b0;
//			A [11:8] = 4'b0;
//			A [7:4] = 4'b0;
//			A [3:0] = 4'b0;
		end
//realiza el desplazamiento de informacion de registros para liberar a a11
      else if(desplaza == 1'b1)
		begin
			a0 = 4'b0;
			a1 = b0;
			a2 = b1;
			a3 = b2;
			a4 = b3;
			a5 = b4;
			a6 = b5;
			a7 = b6;
			a8 = b7;
			a9 = b8;
//			desplaza = 0;
			bandera = 1'b1;
		end
		else if(desplaza_inv == 1'b1)
		begin
			a0 = b1;
			a1 = b2;
			a2 = b3;
			a3 = b4;
			a4 = b5;
			a5 = b6;
			a6 = b7;
			a7 = b8;
			a8 = b9;
			a9 = 4'b0;
		end
//agrega el nuevo numero en el registro a11
		else if(bandera == 1'b1 && pos_actual[0] == 1'b1)
   	begin	
			a0 = 4'b0000;
			bandera = 1'b0;
		end//0
		else if(bandera == 1'b1 && pos_actual[1] == 1'b1)
   	begin	
			a0 = 4'b0001;
			bandera = 1'b0;
		end//1
		else if(bandera == 1'b1 && pos_actual[2] == 1'b1)
   	begin	
			a0 = 4'b0010;
			bandera = 1'b0;
		end//2
		else if(bandera == 1'b1 && pos_actual[3] == 1'b1)
   	begin	
			a0 = 4'b0011;
			bandera = 1'b0; 
		end//3
		else if(bandera == 1'b1 && pos_actual[4] == 1'b1)
   	begin	
			a0 = 4'b0100;
			bandera = 1'b0; 
		end//4
		else if(bandera == 1'b1 && pos_actual[5] == 1'b1)
   	begin	
			a0 = 4'b0101;
			bandera = 1'b0; 
		end//5
		else if(bandera == 1'b1 && pos_actual[6] == 1'b1)
   	begin	
			a0 = 4'b0110;
			bandera = 1'b0; 
		end//6
		else if(bandera == 1'b1 && pos_actual[7] == 1'b1)
   	begin	
			a0 = 4'b0111;
			bandera = 1'b0; 
		end//7
		else if(bandera == 1'b1 && pos_actual[8] == 1'b1)
		begin
   		a0 = 4'b1000;//8
			bandera = 1'b0;
		end
		else if(bandera == 1'b1 && pos_actual[9] == 1'b1)
   	begin	
			a0 = 4'b1001;
			bandera = 1'b0; 
		end//9
		else if(bandera == 1'b1 && pos_actual[10] == 1'b1)
   	begin	
			a0 = 4'b1010;
			bandera = 1'b0; 
		end//10
		else if(bandera == 1'b1 && pos_actual[11] == 1'b1)
   	begin	
			a0 = 4'b1011;
			bandera = 1'b0; 
		end//11
		else if(bandera == 1'b1 && pos_actual[12] == 1'b1)
   	begin	
			a0 = 4'b1100;
			bandera = 1'b0; 
		end//12
		else if(bandera == 1'b1 && pos_actual[13] == 1'b1)
		begin	
			a0 = 4'b1101;
			bandera = 1'b0; 
		end//13
		else if(bandera == 1'b1 && pos_actual[14] == 1'b1)
   	begin	
			a0 = 4'b1110;
			bandera = 1'b0; 
		end//14
		else if(bandera == 1'b1 && pos_actual[15] == 1'b1)
   	begin	
			a0 = 4'b1111;
			bandera = 1'b0; 
		end//15

		else
		begin
			a0 = a0;
			a1 = a1;
			a2 = a2;
			a3 = a3;
			a4 = a4;
			a5 = a5;
			a6 = a6;
			a7 = a7;
			a8 = a8;
			a9 = a9;	
			
			b0 = a0;
			b1 = a1;
			b2 = a2;
			b3 = a3;
			b4 = a4;
			b5 = a5;
			b6 = a6;
			b7 = a7;
			b8 = a8;
			b9 = a9;
			
//			A [39:36] = a9;
//			A [35:32] = a8;
//			A [31:28] = a7;
//			A [27:24] = a6;
//			A [23:20] = a5;
//			A [19:16] = a4;
//			A [15:12] = a3;
//			A [11:8] = a2;
//			A [7:4] = a1;
//			A [3:0] = a0;
		end
	end
	
	assign A [39:36] = a9;
	assign A [35:32] = a8;
	assign A [31:28] = a7;
	assign A [27:24] = a6;
	assign A [23:20] = a5;
	assign A [19:16] = a4;
	assign A [15:12] = a3;
	assign A [11:8] = a2;
	assign A [7:4] = a1;
	assign A [3:0] = a0;

endmodule
