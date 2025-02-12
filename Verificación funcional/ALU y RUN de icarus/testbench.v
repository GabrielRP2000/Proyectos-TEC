`include "all.v"
`timescale 1ns / 1ps


///////////////////////////////////////////////////////////////////////////////////////Clase que me genera todos los valores randoms/////////////////////////////////////////////////////

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




    class generador_de_randoms;

                //Generacion Aleatoria de Op -> opA/opB/opE/opI
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

///////////////////////////////////////////////////////////////////////////////////////Clase del modulo BancodeInterfaz_test/////////////////////////////////////////////////////

    class BancoDeInterfaz_test;
        //Declaro las variables de entrada y salidas O necesarias 
        bit [15:0] Data;
        bit rst;
        bit WR;
        bit [1:0] opEN, opIN;
        bit [15:0] RE, RI;
        bit [15:0] REBDI_real, RIBDI_real;
        bit [15:0] ES, CS, SS, DS;
        
            //CUIDEN QUE NO SE LLAMEN IGUAL LA DECLARACION DE VARIABLES DE ARRIBA CON LAS QUE RECIBE EL CONSTRUCTOR, SI NO VAN A RECIBIR 0 COMO DATOS
            function new(bit RST,bit [15:0] DATA,bit WBDI,bit [1:0] opE, bit [1:0] opI, bit [15:0] REBDI);
                
                this.rst = RST;
                this.Data = DATA;
                this.WR = WBDI;
                this.opEN = opE;
                this.opIN = opI;
                this.REBDI_real = REBDI;
                $display("Constructor: rst=%b, Data=%h, WR=%b, opE=%b, opI=%b, REBDI=%b", rst, Data, WR, opE, opI,REBDI);
            endfunction : new

//////////////////////////////////////////////////////////////////////////Task para preparar los datos para el scoreboard//////////////////////////////////////////

            task scoreboard_banco();
                bit flag;
                bit DONE;
                repeat(1) begin : test_banco
                flag = 1'b0;
                    //scoreboard para corroborar que se esta escribiendo correctamente en los registros
                    if (this.WR==1) begin
                        case (this.opEN)
                            2'b00 : ES = Data;
                            2'b01 : CS = Data;
                            2'b10 : SS = Data;
                            2'b11 : DS = Data;
                        endcase // case (selection_choice)
                        //Bandera para que si se escribe en registros se pase al mux
                        flag = 1'b1;
                    end else begin
                        $display("No se escribe en los registros al tener el valor de 0 de write");
                        //$display("El valor de opE es: %b y el de opI es: %b", this.opE,this.opI);
                        //$display("El valor de data es: %b", this.Data);
                    end
                    //scoreboard que va a verificar que la salida del mux de rebdi sea la correcta
                    if(flag==1'b1) begin
                        case (this.opEN)
                            2'b00 : RE = ES;
                            2'b01 : RE = CS;
                            2'b10 : RE = SS;
                            2'b11 : RE = DS;
                        endcase
                        case (this.opIN)
                            2'b00 : RI = ES;
                            2'b01 : RI = CS;
                            2'b10 : RI = SS;
                            2'b11 : RI = DS;
                        endcase
                        flag = 1'b0;
                        DONE =1;
                    end

//////////////////////////////////////////////////////////////////////////////Scoreboard del banco de interfaz/////////////////////////////////////////////////
                    // Código a ejecutar sin dependencias de variables
                    if(DONE==1) begin
                        if (RE !== this.REBDI_real) begin
                                $display("\n\nERROR: Valor incorrecto en salida del Mux. Esperado: %h, Obtenido: %h", RE, this.REBDI_real);
                        end else begin
                                $display("\n\nOK: Valor correcto en salida del Mux. Esperado: %h, Obtenido: %h", RE, this.REBDI_real);
                        end
                    end
///////////////////////////////////////////////////////////////////////////Termina Scoreboard///////////////////////////////////////////////////////////////////




                end : test_banco
            endtask : scoreboard_banco


    endclass : BancoDeInterfaz_test

//////////////////////////////////////////////////Clase del modulo DatosINOUT Registros de Datos///////////////////////////////////////////////////////////////////////////
/*
class DatosINOUT_RegistrodeDatos;
        //Declaro las variables de entrada y salidas necesarias
        bit [7:0] Databus;
        bit rst;
        bit ENARD;
        bit W;
        bit clk;
        reg [7:0] queue [0:5];
        bit [15:0] DatoIN1_test, DatoIN2_test, DatoIN3_test;
        bit [15:0] DatoIN1, DatoIN2, DatoIN3;
        bit [15:0] opDatoIN1;
        
            function new( bit CLK, bit RST,bit [7:0] DATA_BUS,bit w, bit ENA_RD, bit [15:0] Dato_IN1, bit [15:0] Dato_IN2, bit [15:0] Dato_IN3);
                this.rst = RST;
                this.clk = CLK;
                this.Databus = DATA_BUS;
                this.ENARD = ENA_RD;
                this.W = w; 
                this.DatoIN1 = Dato_IN1;
                this.DatoIN2 = Dato_IN2;
                this.DatoIN3 = Dato_IN3;   
                //$display("Constructor: rst=%b, Data=%h, W=%b, DatoIN1=%h, DatoIN2=%h, DatoIN3=%h", rst, Databus, W, DatoIN1, DatoIN2, DatoIN3);
            endfunction : new
        ////////////////////////////Task para preparar los datos para el scoreboard///////////////////////////////////

            task scoreboard_DatosINOUT_Reg();
                bit flag;
                bit DONE;
                repeat(1) begin : test_DatosINOUT
                flag = 1'b0;
                    //scoreboard para corroborar que se esta escribiendo correctamente en los registros
                    
                    //always @(posedge this.rst) begin
                        //if (this.ENARD==1) begin
                            //if (this.rst) begin
                            //    queue[0] <= 8'h00;
                            //    queue[1] <= 8'h00;
                            //    queue[2] <= 8'h00;
                            //    queue[3] <= 8'h00;
                            //    queue[4] <= 8'h00;
                            //    queue[5] <= 8'h00;
                            //end else begin
                            //    queue[5] <= queue[4];
                            //    queue[4] <= queue[3];
                            //    queue[3] <= queue[2];
                            //    queue[2] <= queue[1];
                            //    queue[1] <= queue[0];
                            //    queue[0] <= this.Databus;
                            //end
                        //end else begin
                        //    $display("No se escribe en los registros al tener el valor de 0 de write");
                        //end
                        //assign opDatoIN1 = {queue[1], queue[0]};
                        //assign DatoIN2_test = {queue[2], queue[3]};
                        //assign DatoIN3_test = {queue[4], queue[5]};
                        //Bandera para que si se escribe en registros se pase al mux
                        flag = 1'b1;
                    //end
                    //scoreboard que va a verificar que la salida del mux de rebdi sea la correcta
                    if(flag==1'b1) begin
                        case (this.W)
                            1'b0 : DatoIN1_test = {8'b0, opDatoIN1[7:0]};
                            1'b1 : DatoIN1_test = {opDatoIN1[7:0], opDatoIN1[15:8]};
                        endcase
                        flag = 1'b0;
                        DONE =1;
                    end

                //////////////////////////////////////////////////////////////////////////////Scoreboard del banco de interfaz/////////////////////////////////////////////////
                    // Código a ejecutar sin dependencias de variables
                    if(DONE==1) begin
                        if (DatoIN1_test != this.DatoIN1) begin
                                $display("\n\nERROR: Valor incorrecto en salida del Mux. Esperado: %h, Obtenido: %h", DatoIN1_test, this.Dato_IN1);
                        end else begin
                                $display("\n\nOK: Valor correcto en del Mux. Esperado: %h, Obtenido: %h", DatoIN1_test, this.Dato_IN1);
                        end
                        if (DatoIN2_test != this.DatoIN2) begin 
                                $display("\n\nERROR: Valor incorrecto en salida de los registros. Esperado: %h, Obtenido: %h", DatoIN2_test, this.Dato_IN2);
                        end else begin
                                $display("\n\nOK: Valor correcto en salida de los registros. Esperado: %h, Obtenido: %h", DatoIN2_test, this.Dato_IN2);
                        end
                        if (DatoIN3_test != this.DatoIN3) begin
                                $display("\n\nERROR: Valor incorrecto en salida de los registros. Esperado: %h, Obtenido: %h", DatoIN3_test, this.Dato_IN3);
                        end else begin
                                $display("\n\nOK: Valor correcto en salida salida de los registros. Esperado: %h, Obtenido: %h", DatoIN3_test, this.Dato_IN3);
                        end
                    end
                ///////////////////////////////////////////////////////////////////////////Termina Scoreboard///////////////////////////////////////////////////////////////////

                end : test_DatosINOUT
            endtask : scoreboard_DatosINOUT_Reg


endclass : DatosINOUT_RegistrodeDatos
*/
///////////////////////////////////////////////////////////////////////////////////////Modulo principal o funcion main/////////////////////////////////////////////////////

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
    
    //Variables para guardar los registros
    bit [15:0] ES, CS, SS, DS;
/*
///////////////////////////////////////////////////////////////////////////////////////Funciones para guardar los valores de los registros y compararlos en el scoreboard//////////////////

    //Funcion para almacenar el valor de los registros de Banco de interfaz
    function void save_reg(bit [3:0] sel_reg);
          case (sel_reg)
            2'b00 : ES = DATA ;
            2'b01 : CS = DATA ;
            2'b10 : SS = DATA ;
            2'b11 : DS = DATA ;
          endcase
    endfunction : save_reg
*/
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


    // Crear una instancia de la clase
    generador_de_randoms gen;
    BancoDeInterfaz_test Banco_gen;
    //DatosINOUT_RegistrodeDatos Datos_Reg;

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
					
                    //Banco_gen = new(RST,DATA,WBDI,opE,opI,REBDI);

                    //DATA_BUS = DATA[7:0]; //Modificar despues con el dato correcto por mientras lo quemo
                    //W = opI[0];
                    //Datos_Reg = new(CLK,RST, DATA_BUS, W, ENARD, DatoIN1, DatoIN2, DatoIN3); 

//////////////////////////////////////////////////////////////////////////////////////ScoreBoard///////////////////////////////////////////////////////////////////////

                    //De esta forma llaman al tarea que contiene la clase de cada modulo
                    //Banco_gen.scoreboard_banco();
                    // Imprimir los valores
                    //$display("El valor de opE es: %b y el de opI es: %b", opE,opI);
                    //$display("El valor de data es: %b", DATA);
                    //$display("El valor de REBDI es: %b", REBDI);
                    //$display("\n\nHola Mundo\n");
                    //Datos_Reg.scoreboard_DatosINOUT_Reg();

                end
            end : tester

   
endmodule : principal
 