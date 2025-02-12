//Tester for BancodeRegistros
//How to run
// 	-> iverilog -g2012 -o test Test.sv
//	-> vvp test
//
`include "BancoDeRegistros.v" 
`include "DetectorZero.v" 
`include "Mux16a1de16bits.v" 
`include "Mux2a1de16bits.v" 
`include "Mux2a1de8bits.v"
`include "Mux4a1de16bits.v" 
`include "Mux8a1de16bits.v" 
`include "Reg16bitsEnaDown.v" 
`include "Reg8bitsEnaDown.v" 
`include "RomSeleccionBancoDeEjecucion.v" 
`include "RomSeleccionInterfazBancoDeEjecucion.v" 
`include "SemiAdder16bits3op.v" 
`include "ACT16bits.v" 
`include "SemiAdder16bits.v" 
`include "FullAdder.v" 
`include "SemiAdderFin.v" 
`include "SemiAdderIni.v"

module test;

//Definiciones iniciales /////////////////////////////////////////////////
   typedef enum bit[2:0] { no_op  = 3'b000,
                           wr_op  = 3'b001, 
                           rd_op  = 3'b010,
                           dir_op = 3'b011,
                           int_op = 3'b100,
                           rst_op = 3'b111} operation;

   bit CLK;
   bit RST;
   bit DONE;
   bit [15:0] A;
   bit [7:0] DatoIN;
   bit [23:0] DESP;
   bit [1:0] mod;
   bit [2:0] RM;
   bit [3:0] opER,opEW;
   bit WR,LDI;
   bit [3:0] DirST;
   bit [2:0] SelIn;
   wire CXZ;
   wire [15:0] R,RI;
   byte unsigned iteration;

   operation my_operation;

//Variables para guardar los registros
   bit [15:0] SP,BP,SI,DI;
   bit [7:0] AL,AH,BL,BH,CL,CH,DL,DH;

//Instaciacion del Modulo Principal
   BancoDeEjecucion DUT (.CLK, .RST, .A, .DatoIN, .DESP, .mod, 
		         .RM, .opER, .opEW, .DirST, .SelIn, 
		         .WR, .LDI, .CXZ, .R, .RI);
 
//Definiciones Iniciales -> CLK
   initial begin
      CLK = 1'b0;
      forever begin
         #10;
         CLK = ~CLK;
      end
   end

   initial begin
      #10000 $finish;
   end

//Funciones de Ayuda /////////////////////////////////////////////////////

//Generacion Aleatoria de Op -> opER/opEW
  function bit[3:0] get_op();
     return $random;
  endfunction : get_op

//Generacion aleatoria de DirST
   function bit[3:0] get_dirST();
      return $random;
   endfunction : get_dirST

//Generacion aleatoria de SelIn
   function bit[2:0] get_selIn();
      return $random;
   endfunction : get_selIn

//Generacion aleatoria de mod
   function bit[1:0] get_mod();
      return $random;
   endfunction : get_mod
	
//Generacion aleatoria de RM
   function bit[2:0] get_RM();
      	return $random;
   endfunction : get_RM

//Generacion Aleatoria de Dato de 16 bits
   function bit[15:0] get_data16();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 16'h0000;
      else if (zero_ones == 2'b11)
        return 16'hFFFF;
      else
        return $random;
   endfunction : get_data16

//Generacion Aleatoria de Dato de 8 bits
   function bit[7:0] get_data8();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data8

//Generacion Aleatoria de Dato de 24 bits
   function bit[23:0] get_data24();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 24'h000000;
      else if (zero_ones == 2'b11)
        return 24'hFFFFFF;
      else
        return $random;
   endfunction : get_data24

//Funcion GET OPT -> genera una opcion de operacion

   function operation get_operation();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return no_op;
        3'b001 : return no_op;
        3'b010 : return wr_op;
        3'b011 : return rd_op;
        3'b100 : return dir_op;
        3'b101 : return int_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
      endcase
   endfunction : get_operation

//Funcion Save Reg para guardar los valores externamente
  
   function void save_reg(); 
      case (opEW)
	4'b0000 : AL = A[7:0] ;
        4'b0001 : CL = A[7:0] ;
        4'b0010 : DL = A[7:0] ;
        4'b0011 : BL = A[7:0] ;
        4'b0100 : AH = A[7:0] ;
        4'b0101 : CH = A[7:0] ;
        4'b0110 : DH = A[7:0] ;
        4'b0111 : BH = A[7:0] ;
	4'b1000 : {AH,AL} = A ;
        4'b1001 : {CH,CL} = A ;
        4'b1010 : {DH,DL} = A ;
        4'b1011 : {BH,BL} = A ;
        4'b1100 : SP = A ;
        4'b1101 : BP = A ;
        4'b1110 : SI = A ;
        4'b1111 : DI = A ;
      endcase
   endfunction : save_reg

//Funcion Read Reg para leer los valores guardados externamente

   function bit[15:0] read_reg(); 
      case (opER)
	4'b0000 : return {8'h00,AL} ;
        4'b0001 : return {8'h00,CL} ;
        4'b0010 : return {8'h00,DL} ;
        4'b0011 : return {8'h00,BL} ;
        4'b0100 : return {8'h00,AH} ;
        4'b0101 : return {8'h00,CH} ;
        4'b0110 : return {8'h00,DH} ;
        4'b0111 : return {8'h00,BH} ;
	4'b1000 : return {AH,AL} ;
        4'b1001 : return {CH,CL} ;
        4'b1010 : return {DH,DL} ;
        4'b1011 : return {BH,BL};
        4'b1100 : return SP ;
        4'b1101 : return BP ;
        4'b1110 : return SI ;
        4'b1111 : return DI ;
      endcase
   endfunction : read_reg

//Funcion Get Desp para obtener el desplazamiento a usar

   function bit[15:0] get_desp ();
      case (mod)
	 2'b00 : return 16'h0000;
   	 2'b01 : return {8'b0,DESP[7:0]};
	 2'b10 : return DESP[15:0];
	 2'b11 : return 16'h0000;
      endcase
   endfunction : get_desp


//Funcion Get Dir para obtener la direccion exacta

   function bit[15:0] get_exact_dir ();
      bit [15:0] my_desp;
      bit [15:0] direction;

      my_desp = get_desp();

      case (RM)
         3'b000 : direction = {BH,BL} + SI + my_desp;
         3'b001 : direction = {BH,BL} + DI + my_desp;
         3'b010 : direction = BP + SI + my_desp;
         3'b011 : direction = BP + DI + my_desp;
         3'b100 : direction = SI + my_desp;
         3'b101 : direction = DI + my_desp;
         3'b110 : direction = BP + my_desp;
         3'b111 : direction = {BH,BL} + my_desp;
      endcase
      //condicional para direccionamiento directo
      if ((mod == 2'b00) && (RM == 3'b110))
	     direction = DESP[15:0]; 

      return direction;
   endfunction : get_exact_dir

//Funcion Get Int para obtener la direccion de interrupcion

   function bit[15:0] get_int ();
      case (SelIn)
	 3'b000 : return 16'h0000;
         3'b001 : return 16'h0000;
         3'b010 : return 16'h0008;
         3'b011 : return {6'b0,A[7:0],2'b0};
         3'b100 : return 16'h000c;
         3'b101 : return {8'b0,DESP[21:16],2'b00};
         3'b110 : return 16'h0010;
         3'b111 : return 16'h0000;
      endcase
   endfunction : get_int

//Tester /////////////////////////////////////////////////////////////////

   initial begin : tester
   //Reset inicial
      assign RST = 1'b0;
      @(posedge CLK);
      assign RST = 1'b1;
      @(posedge CLK);
      assign RST = 1'b0;

      //Testing
      iteration = 0;
      repeat (100) begin
	 @(posedge CLK);
	 DONE = 0;
	 //getting my operation 
         my_operation = get_operation();
	 
	 //Printing for testing
	 $display("Iteration: %0d, Testing: %0d", iteration, my_operation);
	 iteration = iteration + 1; 
 	 case (my_operation)
	    
	    //Do nothing
	    no_op: begin
 	       @(posedge CLK);
	       DONE = 1;
	    end
	    
	    //Reset the system
	    rst_op: begin
	       RST = 1'b1;
      	       @(posedge CLK);
               RST = 1'b0;
	       DONE = 1;
	    end

	    //Write a value
	    wr_op: begin
               A = get_data16();
	       opEW = get_op();
	       WR = 1'b1;
	       @(posedge CLK);
	       WR = 1'b0;
	       save_reg();
	       DONE = 1;
            end

	    //RD a value
	    rd_op: begin
	       opER = get_op();
	       @(posedge CLK);
	       DONE = 1;
	    end

	    //Get a direction
	    dir_op: begin
	       mod = get_mod();
	       RM = get_RM();
	       DESP = get_data24();
	       DirST = get_dirST();
	       LDI = $random;
	       @(posedge CLK);
   	       DONE = 1;
	    end
	    
	    //Get an InterruptioN
	    int_op: begin
	       DirST = get_dirST();
	       DatoIN = get_data8();
	       SelIn = get_selIn();
	       @(posedge CLK);
	       DONE = 1;
	    end
	   
	    //default
	    default: begin
	    end

         endcase
      end
      //end Testing	
   end : tester

//SCORE BOARD ////////////////////////////////////////////////////////////

   always @(posedge DONE) begin : scoreboard
      bit [15:0] predicted_value;
      #1;
      case (my_operation)
	 //Write Data 
         wr_op: begin
            opER = opEW;
	    if (opEW[3] == 1)
	        predicted_value = {8'h00,A[7:0]};
            else 
		predicted_value = A;

	    $display("A: %0h, R: %0h, opEW: %0h, opER: %0h",A,R,opEW,opER);
	    if (R != predicted_value) 
               $error("FAILED -> RESULT: %0h ; PREDICTED: %0h", R, predicted_value);
	 end
	 //Read Data
	 rd_op: begin
	   predicted_value = read_reg();

	   $display("R: %0h, P: %0h, opER: %0h",R,predicted_value,opER);
	   if (R != predicted_value) 
               $error("FAILED -> RESULT: %0h ; PREDICTED: %0h", R, predicted_value);
         end
	 //Direccionamiento
	 dir_op: begin
           predicted_value = get_exact_dir();

	   $display("RI: %0h, MOD: %0h, RM: %0h, DESP: %0h, PREDICTED: %0h",RI,mod,RM,DESP,predicted_value);
	   if (RI != predicted_value) 
               $error("FAILED -> RESULT: %0h ; PREDICTED: %0h", RI, predicted_value);
         end
	 //Interrupcion
	 int_op: begin
	    predicted_value = get_int();

	    $display("SelIn, DESP: %0h, RI: %0h, PREDICTED: %0h",SelIn,RI,DESP,predicted_value);
	    if (RI != predicted_value) 
               $error("FAILED -> RESULT: %0h ; PREDICTED: %0h", RI, predicted_value);

         end
	 //Default case for RST and No_op
	 default: begin
         //Do nothing
         end
      endcase

   end

endmodule : test

//////////////////////////////////////////////////////////////////////////

