`include "all.v"
`timescale 1ns / 1ps



typedef enum bit[5:0] { ADD =  6'b000000,  //// de aqui
							OR =   6'b000001,  
							ADC =  6'b000010,  
							SBB =  6'b000011,  
							AND =  6'b000100,  
							SUB =  6'b000101,  
							XOR =  6'b000110,   /// hasta aqui ocupa 2 A
							CMP =  6'b000111,  
							ROL =  6'b001000,  
							ROR =  6'b001001,   //// de aqui
							RCL =  6'b001010,  
							RCR =  6'b001011, 
							SHL =  6'b001100,  //afectados por el V
							SHR =  6'b001101,  
							SAL =  6'b001110,  
							SAR =  6'b001111,   ///hasta aqui
							AAA =  6'b010000,  
							AAS =  6'b010101,  
							DAA =  6'b011000,  
							DAS =  6'b011101,  
							MUL =  6'b100000, // 8BITS     ///de aqui
							MUL2 = 6'b100001, // 16BITS 
							IMUL = 6'b100010, // 8BITS
							IMUL2 =6'b100011, // 16BITS   ///hasta aqui ocupa 2 A
							DIV =  6'b100100, // 8BITS    //// de aqui
							DIV2 = 6'b100101, // 16BITS
							IDIV = 6'b100110, // 8BITS
							IDIV2 =6'b100111, // 16BITS   //hasta aqui ocupa 3 A
							NOT =  6'b101000,  
							NEG =  6'b101001,  
							CBW =  6'b101100, 
							CWD =  6'b101101, 
							AAM =  6'b101110, 
							AAD =  6'b101111}operacion;


///////////////////////////////////////////////////////////////////////////////////////Clase que me genera todos los valores randoms/////////////////////////////////////////////////////


	class generador_de_randoms;

               
                function bit[5:0] get_op();
                    bit [4:0] op_choice;
					bit op_choice2;
					
					op_choice = $random;
					op_choice2 = $random;
					case (op_choice)
						5'b00000 : begin
							if(op_choice2 == 0)
								return ADD;
							else
								return AAM;
						end
						5'b00001 : begin
							if(op_choice2 == 0)
								return OR;
							else
								return AAD;
						end
						5'b00010 : return ADC;
						5'b00011 : return SBB;
						5'b00100 : return AND;
						5'b00101 : return SUB;
						5'b00110 : return XOR;
						5'b00111 : return CMP;
						5'b01000 : return ROL;
						5'b01001 : return ROR;
						5'b01010 : return RCL;
						5'b01011 : return RCR;
						5'b01100 : return SHL;
						5'b01101 : return SHR;
						5'b01110 : return SAL;
						5'b01111 : return SAR;
						5'b10000 : return AAA;
						5'b10001 : return AAS;
						5'b10010 : return DAA;
						5'b10011 : return DAS;
						5'b10100 : return MUL;
						5'b10101 : return MUL2;
						5'b10110 : return IMUL;
						5'b10111 : return IMUL2;
						5'b11000 : return DIV;
						5'b11001 : return DIV2;
						5'b11010 : return IDIV;
						5'b11011 : return IDIV2;
						5'b11100 : return NOT;
						5'b11101 : return NEG;
						5'b11110 : return CBW;
						5'b11111 : return CWD;
					endcase // case (op_choice)
                endfunction : get_op

                //Generacion Aleatoria de DATA de 16 bits
                function bit[15:0] get_data16();
                      bit [1:0] zero_ones;
                      zero_ones = $random;
                      if (zero_ones == 2'b00)
                        return 16'h0000;
                      else if (zero_ones == 2'b11)
                        return 16'hFFFF;
                      else
                        return $random ;
                endfunction : get_data16

    endclass : generador_de_randoms


module principal;


    bit CLK;
    bit RST;
	bit [15:0] A,a,b,d;
    bit V;
    bit [5:0] op;
    bit WA;
    bit WB;
    bit WD;
    bit ENADi;
    bit [1:0] WR;
    bit [2:0] opFL;
	bit [31:0]Rt;
    
    output wire [15:0] R1,R2,FLAGS;
    output wire [5:0] FL;
    output wire FINP,IF;
	
    bit [10:0] iteration;
    

    ALU DUT (.CLK,.RST,.A,.V,.op,.WA,.WB,.WD,.ENADi,.WR,.opFL,.R1,.R2,.FLAGS,.FL,.FINP,.IF);

///////////////////////////////////////////////////////////////////////////////////////Definiciones Iniciales -> CLK/////////////////////////////////////////////////////
            initial begin
                CLK = 1'b0;
                forever begin
                    #10;
                    CLK = ~CLK;
                end
            end

            initial begin
                #1000000 $finish;
            end

///////////////////////////////////////////////////////////////////////////////////////Instancias de las clases/////////////////////////////////////////////////////

    generador_de_randoms gen;

///////////////////////////////////////////////////////////////////////////////////////Tester del proyecto en general/////////////////////////////////////////////////////

            initial begin : tester
            //Secuencia de reset para poner el sistema en un estado conocido
            assign RST = 1'b0;
            @(posedge CLK);
            assign RST = 1'b1;
            @(posedge CLK);
            assign RST = 1'b0;

            //Variable para ir imprimiendo luego el numero de iteracion
            iteration = 0;
                repeat (1000) begin
                
					iteration =  iteration + 1;
					$display("\nIteracion: %0d", iteration);
					gen = new();
					op = gen.get_op();
					//$display("\nOperacion %0d , %0b",op,op);
					if (op <= 6'b000111)begin
						A = gen.get_data16();
						a = A;
						WA = 1;
						@(negedge CLK);
						WA = 0;
						gen = new();
						A = gen.get_data16();
						b = A;
						WB = 1;
						@(negedge CLK);
						WB = 0;
						WR = 3;
						@(negedge CLK);
						WR = 0;
						$display("Operacion %0b = A: %0d, B: %0d, R: %0d, Flags: %0b",op, a, b, R1, FL);
					end
					else if(op >= 6'b100100 && op <= 6'b100111) begin  ///division
						A = gen.get_data16();
						a = A;
						WA = 1;
						@(negedge CLK);
						WA = 0;
						gen = new();
						A = gen.get_data16();
						b = A;
						WB = 1;
						@(negedge CLK);
						WB = 0;
						gen = new();
						A = gen.get_data16();
						d = A;
						WD = 1;
						@(negedge CLK);
						WD = 0;
						ENADi = 1;
						#100
						ENADi = 0;
						while (FINP == 0)begin
							@(negedge CLK);
							//$display("\nWhile");
						end
						WR = 3;
						@(negedge CLK);
						WR = 0;
						$display("Operacion %0b = A: %0d, B: %0d, D: %0d, Resultado: %0d, residuo: %0d, Flags: %0b",op, a, b, d, R1,R2,FL);
						
					end
					else if(op >= 6'b100000 && op <= 6'b100011) begin //multiplicaciones
						A = gen.get_data16();
						a = A;
						WA = 1;
						@(negedge CLK);
						WA = 0;
						gen = new();
						A = gen.get_data16();
						b = A;
						WB = 1;
						@(negedge CLK);
						WB = 0;
						@(negedge CLK);
						@(negedge CLK);
						Rt = {R2,R1};
						WR = 3;
						@(negedge CLK);
						WR = 0;
						$display("Operacion %0b = A: %0d, B: %0d, R: %0d, Flags: %0b",op, a, b, Rt,FL);
						
					end
					else if((op >= 6'b000111 && op <= 100000) || op >= 6'b101000)begin // || op == 6'b101001 || op == 6'b101100 || op == 6'b101101 || op == 6'b101110 || op == 6'b101111)begin
						A = gen.get_data16();
						a = A;
						WA = 1;
						@(negedge CLK);
						@(negedge CLK);
						WA = 0;
						WR = 3;
						@(negedge CLK);
						WR = 0;
						$display("Operacion %0b = A: %0d, R: %0d, Flags: %0b",op, a, R1, FL);
					end
                end
            end : tester

   
endmodule : principal
 