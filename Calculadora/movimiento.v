
module movimiento(clk,BA,BB,BI,BD,pos_actual,Pos);
  	input clk,BA,BB,BI,BD; //Botones utilizados por los jugadores para desplazarse por el tablero
  	output reg [25:0] pos_actual;
	output reg [4:0] Pos;
	
	
	always @(posedge clk)
 	begin
      case(pos_actual)//posicion en el tablero
 			1: begin //0
              	if(BD==1'b1)
   					pos_actual= 2;//se mueve al cuadro 1
              	else if(BA==1'b1)
   					pos_actual= 256;//se mueve al cuadro 8
              	else
       				pos_actual = 1;
 			end 
 			2: begin //1
              if(BD==1'b1)
   					pos_actual= 4;//se mueve al cuadro 2
              else if (BI==1'b1)
   					pos_actual= 1;//se mueve al cuadro 0
              else if (BA==1'b1)
   					pos_actual= 512;//se mueve al cuadro 9
              else
                	pos_actual = 2;
 			end
 			4: begin //2
              if(BI==1'b1)
   					pos_actual = 2;//se mueve al cuadro 1
              else if (BD==1'b1)
   					pos_actual = 8;//se mueve al cuadro 3
              else if (BA==1'b1)
   					pos_actual= 1024;//se mueve al cuadro A
              else
                	pos_actual = 4;
 			end
 			8: begin //3
              if(BD==1'b1)
   					pos_actual= 16;//se mueve al cuadro 4
              else if (BI==1'b1)
   					pos_actual= 4;//se mueve al cuadro 2
              else if (BA==1'b1)
   					pos_actual= 2048;//se mueve al cuadro B
              else
                	pos_actual = 8;
 			end 
         16: begin //4
              if(BD==1'b1)
   					pos_actual= 32;//se mueve al cuadro 5
              else if (BA==1'b1)
   					pos_actual= 4096;//se mueve al cuadro C
              else if (BI==1'b1)
   					pos_actual= 8;//se mueve al cuadro 3
              else
                	pos_actual = 16;
 			end 
         32: begin //5
              if(BI==1'b1)
   					pos_actual= 16;//se mueve al cuadro 4
              else if (BD==1'b1)
   					pos_actual= 64;//se mueve al cuadro 6
              else if (BA==1'b1)
   					pos_actual= 8192;//se mueve al cuadro D
              else
                	pos_actual = 32;
 			end 
         64: begin //6
              if(BD==1'b1)
   					pos_actual= 128;//se mueve al cuadro 7
              else if (BA==1'b1)
   					pos_actual= 16384;//se mueve al cuadro E
              else if (BI==1'b1)
   					pos_actual= 32;//se mueve al cuadro 5
              else
                	pos_actual = 64;
 			end 
         128: begin //7
              if(BD==1'b1)
   					pos_actual= 33554432;//se mueve al cuadro (=)
              else if (BA==1'b1)
   					pos_actual= 32768;//se mueve al cuadro F
              else if (BI==1'b1)
   					pos_actual= 64;//se mueve al cuadro 6
              else
                pos_actual = 128;
 			end 
         256: begin //8
					if (BA==1'b1)
   					pos_actual= 65536;//se mueve al cuadro (,)
					else if (BD==1'b1)
   					pos_actual= 512;//se mueve al cuadro 9
					else if (BB==1'b1)
   					pos_actual= 1;//se mueve al cuadro 0
					else
						pos_actual = 256;
 			end
			512: begin //9
					if (BA==1'b1)
   					pos_actual= 131072;//se mueve al cuadro (raiz)
					else if (BD==1'b1)
   					pos_actual= 1024;//se mueve al cuadro A
					else if (BB==1'b1)
   					pos_actual= 2;//se mueve al cuadro 1
					else if (BI==1'b1)
   					pos_actual= 256;//se mueve al cuadro 8
					else
						pos_actual = 512;
 			end
			1024: begin //A
					if (BA==1'b1)
   					pos_actual= 262144;//se mueve al cuadro (x)
					else if (BD==1'b1)
   					pos_actual= 2048;//se mueve al cuadro B
					else if (BB==1'b1)
   					pos_actual= 4;//se mueve al cuadro 2
					else if (BI==1'b1)
   					pos_actual= 512;//se mueve al cuadro 9
					else
						pos_actual = 1024;
 			end
			2048: begin //B
					if (BA==1'b1)
   					pos_actual= 524288;//se mueve al cuadro (/)
					else if (BD==1'b1)
   					pos_actual= 4096;//se mueve al cuadro C
					else if (BB==1'b1)
   					pos_actual= 8;//se mueve al cuadro 3
					else if (BI==1'b1)
   					pos_actual= 1024;//se mueve al cuadro A
					else
						pos_actual = 2048;
 			end
			4096: begin //C
					if (BA==1'b1)
   					pos_actual= 1048576;//se mueve al cuadro (+)
					else if (BD==1'b1)
   					pos_actual= 8192;//se mueve al cuadro D
					else if (BB==1'b1)
   					pos_actual= 16;//se mueve al cuadro 4
					else if (BI==1'b1)
   					pos_actual= 2048;//se mueve al cuadro B
					else
						pos_actual = 4096;
 			end
			8192: begin //D
					if (BA==1'b1)
   					pos_actual= 2097152;//se mueve al cuadro (-)
					else if (BD==1'b1)
   					pos_actual= 16384;//se mueve al cuadro E
					else if (BB==1'b1)
   					pos_actual= 32;//se mueve al cuadro 5
					else if (BI==1'b1)
   					pos_actual= 4096;//se mueve al cuadro 0C
					else
						pos_actual = 8192;
 			end
			16384: begin //E
					if (BA==1'b1)
   					pos_actual= 4194304;//se mueve al cuadro (AC)
					else if (BD==1'b1)
   					pos_actual= 32768;//se mueve al cuadro F
					else if (BB==1'b1)
   					pos_actual= 64;//se mueve al cuadro 6
					else if (BI==1'b1)
   					pos_actual= 8192;//se mueve al cuadro D
					else
						pos_actual = 16384;
 			end
			32768: begin //F
					if (BA==1'b1)
   					pos_actual= 8388608;//se mueve al cuadro (<-)
					else if (BD==1'b1)
   					pos_actual= 33554432;//se mueve al cuadro (=)
					else if (BB==1'b1)
   					pos_actual= 128;//se mueve al cuadro 7
					else if (BI==1'b1)
   					pos_actual= 16384;//se mueve al cuadro E
					else
						pos_actual = 32768;
 			end
			65536: begin //16 (,)
					if (BD==1'b1)
   					pos_actual= 131072;//se mueve al cuadro raiz
					else if (BB==1'b1)
   					pos_actual= 256;//se mueve al cuadro 8
					else
						pos_actual = 65536;
 			end
			131072: begin //17 (raiz)
					if (BD==1'b1)
   					pos_actual= 262144;//se mueve al cuadro (x)
					else if (BB==1'b1)
   					pos_actual= 512;//se mueve al cuadro 9
					else if (BI==1'b1)
   					pos_actual= 65536;//se mueve al cuadro (,)
					else
						pos_actual = 131072;
 			end
			262144: begin //18 (x)
					if (BD==1'b1)
   					pos_actual= 524288;//se mueve al cuadro (/)
					else if (BB==1'b1)
   					pos_actual= 1024;//se mueve al cuadro A
					else if (BI==1'b1)
   					pos_actual= 131072;//se mueve al cuadro raiz
					else
						pos_actual = 262144;
 			end
			524288: begin //19 (/)
					if (BD==1'b1)
   					pos_actual= 1048576;//se mueve al cuadro (+)
					else if (BB==1'b1)
   					pos_actual= 2048;//se mueve al cuadro B
					else if (BI==1'b1)
   					pos_actual= 262144;//se mueve al cuadro (x)
					else
						pos_actual = 524288;
 			end
			1048576: begin //20 (+)
					if (BD==1'b1)
   					pos_actual= 2097152;//se mueve al cuadro (-)
					else if (BB==1'b1)
   					pos_actual= 4096;//se mueve al cuadro C
					else if (BI==1'b1)
   					pos_actual= 524288;//se mueve al cuadro (/)
					else
						pos_actual = 1048576;
 			end
			2097152: begin //21 (-)
					if (BD==1'b1)
   					pos_actual= 4194304;//se mueve al cuadro AC
					else if (BB==1'b1)
   					pos_actual= 8192;//se mueve al cuadro D
					else if (BI==1'b1)
   					pos_actual= 1048576;//se mueve al cuadro (+)
					else
						pos_actual = 2097152;
 			end
			4194304: begin //22 (AC)
					if (BD==1'b1)
   					pos_actual= 8388608;//se mueve al cuadro (<-)
					else if (BB==1'b1)
   					pos_actual= 16384;//se mueve al cuadro E
					else if (BI==1'b1)
   					pos_actual= 2097152;//se mueve al cuadro (-)
					else
						pos_actual = 4194304;
 			end
			8388608: begin //23 (<-)
					if (BD==1'b1)
   					pos_actual= 16777216;//se mueve al cuadro C borrar
					else if (BB==1'b1)
   					pos_actual= 32768;//se mueve al cuadro F
					else if (BI==1'b1)
   					pos_actual= 4194304;//se mueve al cuadro E
					else
						pos_actual = 8388608;
 			end
			16777216: begin //24 (C) borrar
					if (BB==1'b1)
   					pos_actual= 33554432;//se mueve al cuadro (=)
					else if (BI==1'b1)
   					pos_actual= 8388608;//se mueve al cuadro (<-)
					else
						pos_actual = 16777216;
 			end
			33554432: begin //25 (=)
					if (BA==1'b1)
   					pos_actual= 16777216;//se mueve al cuadro (C) borrar
					else if (BI==1'b1)
   					pos_actual= 32768;//se mueve al cuadro F
					else
						pos_actual = 33554432;
 			end
			default: pos_actual = 1;
 		endcase
    end
	 
	 	 
	 
	 always@(posedge clk)			//DECODIFICA CADA ENTRADA PARA DAR LA SALIDA EN 5BITS
		case(pos_actual)
			1: Pos = 5'd20;		//0
			2: Pos = 5'd21;		//1
			4: Pos = 5'd22;		//2
			8: Pos = 5'd23;		//3
			16: Pos = 5'd15;		//4
			32: Pos = 5'd16;		//5
			64: Pos = 5'd17;		//6
			128: Pos = 5'd18;		//7
			256: Pos = 5'd10;		//8
			512: Pos = 5'd11;		//9
			1024: Pos = 5'd12;	//A
			2048: Pos = 5'd13;	//B
			4096: Pos = 5'd5;		//C
			8192: Pos = 5'd6;		//D
			16384: Pos = 5'd7;		//E
			32768: Pos = 5'd8;		//F
			65536: Pos = 5'd25;	// .  punto
			131072: Pos = 5'd9;		//RAIZ
			262144: Pos = 5'd2;		// X
			524288: Pos = 5'd3;		// /
			1048576: Pos = 5'd0;		// +
			2097152: Pos = 5'd1;		// -
			4194304: Pos = 5'd19;		//AC
			8388608: Pos = 5'd14;		//BORRAR
			16777216: Pos = 5'd24;		//C borrar
			33554432: Pos = 5'd4;		// =
			default: Pos = 5'd20;			//DEFAULT 0
		endcase

endmodule
