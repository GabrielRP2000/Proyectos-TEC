`include "all.v"
`timescale 1ns / 1ps


module principal;
    
	typedef enum bit[5:0] { ADD =  6'b000000,  //// de aqui
							OR =   6'b000001,  
							ADC =  6'b000010,  
							SBB =  6'b000011,  
							AND =  6'b000100,  
							SUB =  6'b000101/*,  
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
							MUL =  6'b100000,  //	8BITS     ///de aqui
							MUL =  6'b100001,  // 16BITS 
							IMUL = 6'b100010, // 8BITS
							IMUL = 6'b100011, // 16BITS   ///hasta aqui ocupa 2 A
							DIV =  6'b100100,  // 8BITS    //// de aqui
							DIV =  6'b100101,  //  16BITS
							IDIV = 6'b100110, // 8BITS
							IDIV = 6'b100111, // 16BITS   //hasta aqui ocupa 3 A
							NOT =  6'b101000,  
							NEG =  6'b101001,  
							CBW =  6'b101100, 
							CWD =  6'b101101, 
							AAM =  6'b101110, 
							AAD =  6'b101111*/} operacion;
	
	
	
	
    bit CLK;
    bit RST;
	bit [15:0] A,a,b;
    bit V;
    bit [5:0] op;
    bit WA;
    bit WB;
    bit WD;
    bit ENADi;
    bit [1:0] WR;
    bit [2:0] opFL;
    
    wire [15:0] R1,R2,FLAGS;
    output wire [5:0] FL;
    output wire FINP,IF;
	
    byte unsigned iteration;
	
	operacion oper_set;


    ALU DUT (.CLK,.RST,.A,.V,.op,.WA,.WB,.WD,.ENADi,.WR,.opFL,.R1,.R2,.FLAGS,.FL,.FINP,.IF);




function operacion get_oper();
     bit [5:0] oper_choice;
      oper_choice = $random;
      case (oper_choice)
        6'b000000 : return ADD;
        6'b000001 : return OR;
        6'b000010 : return ADC;
        6'b000011 : return SBB;
        6'b000100 : return AND;
        6'b000101 : return SUB;
		/*
		
        6'b0110 : return IpRegister;
        6'b0111 : return BancoInterfaz;
        
        6'b1000 : return Next_Intruction;
        6'b1001 : return wr_bus;
        6'b1010 : return wr_DATOIN;
        4'b1011 : return DirA;
        4'b1100 : return DirB;
        4'b1101 : return IpRegister;
        4'b1110 : return BancoInterfaz;
        4'b1111 : return rst_op;
		*/
      endcase
endfunction : get_oper


	initial
		begin 
			CLK = 0;
			RST = 1;
			A = 0;
			op = 0;
			WA = 0;
			WB = 0;
			WD = 0;
			a = 0;
			b = 0;
			
			oper_set = get_oper();
			
			oper_set = get_oper();
			
			//oper_set = get_oper();
			
			#60 
			RST= 6'b0;
			
			
			#40
			op = 5;
			A = 52493;
			a = A;
			WA = 1;
			#40
			WA = 0;
			A = 52541;
			b = A;
			WB = 1;
			#40
			WB = 0;
			#100
			A = 10;
			WD = 1;
			#40
			WD = 0;
			#100
			WR = 3;//para que me tire las banderas la salida
			$display("\n\nOperacion %0b = A: %0b, B: %0b, R: %0d",op, a, b, R1);
			#40
			op = 6'b0;
			#20
			WR = 0;
			#100
			$display("\nSuma = A: %0b, B: %0b, R: %0b", a, b, R1);
			
			#50000 $finish;
		end
		

///////////////////////////////////////////////////////////////////////////////////////Definiciones Iniciales -> CLK/////////////////////////////////////////////////////
            initial begin
                //CLK = 1'b0;
                forever begin
                    #10;
                    CLK = ~CLK;
                end
            end

            initial begin
                #10000 $finish;
            end
   
endmodule : principal
 