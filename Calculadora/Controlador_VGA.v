
module Controlador_VGA(CLK, RES, Hsync, Vsync, CuentaX, CuentaY);
		
input wire CLK;
input wire RES;
output wire Hsync;
output wire Vsync;
output wire [9:0] CuentaX;
output wire [9:0] CuentaY;

//contador hasta 4 para generar un pixel de recorrido de 25 MHz
reg [1:0] POS_reg;
wire [1:0] POS_sig;
wire POS_actual;
	
always @(posedge CLK, posedge RES)
	if(RES)
		POS_reg <= 0;
	else
		POS_reg <= POS_sig;
	
assign POS_sig = POS_reg + 2'b1; // Incrementar el registro en uno
assign POS_actual = (POS_reg == 0); // Comprueba que se ha contado hasta 4, diviendo la frecuencia a 25MHz
	
// Registros para conocer la posicin actual del recorrido de los pixeles
reg [9:0] Cuenta_H_reg;
reg [9:0] Cuenta_H_sig; 
reg [9:0] Cuenta_V_reg; 
reg [9:0] Cuenta_V_sig; 

// Registros para asignar el cambio de estado o de un pixel a otro
reg Hsync_reg; 
reg Vsync_reg; 
wire Hsync_sig; 
wire Vsync_sig; 
 
// control de registros
always @(posedge CLK, posedge RES) 
	if(RES)  //resetea los valores de los registros
		begin
			Cuenta_V_reg <= 0;
         Cuenta_H_reg <= 0;
         Vsync_reg <= 0;
         Hsync_reg <= 0;
		end
		
	else  //guarda en los registros las posciones actuales correspondientes
		begin
			Cuenta_V_reg <= Cuenta_V_sig;
         Cuenta_H_reg <= Cuenta_H_sig;
         Vsync_reg <= Vsync_sig;
         Hsync_reg <= Hsync_sig;
		end
			
// Siguiente estado de los sincronizadores horizontales y verticales
always @* //Cualquier cambio en las senales dentro de este bloque
	begin
		Cuenta_H_sig = POS_actual ? Cuenta_H_reg == 799 ? 10'b0 : Cuenta_H_reg + 10'b1 : Cuenta_H_reg;//Valor Max en H=799
		Cuenta_V_sig = POS_actual && Cuenta_H_reg == 799 ? (Cuenta_V_reg == 520 ? 10'b0 : Cuenta_V_reg + 10'b1) : Cuenta_V_reg;//Valor Max en V=524
	end
		
// hsync y vsync se activan en bajo
// hsync se activa durante el retrazo horizontal
assign Hsync_sig = Cuenta_H_reg >= 656 && Cuenta_H_reg <= 752; //Comienzo de retraso H=656 final de retraso H=751   

// vsync se activa durante el retrazo vertical
assign Vsync_sig = Cuenta_V_reg >= 490 && Cuenta_V_reg <= 492; //Comienzo de retraso V=513 final del retraso V=514


//Salida
assign Hsync = Hsync_reg;
assign Vsync = Vsync_reg;
assign CuentaX = Cuenta_H_reg;
assign CuentaY = Cuenta_V_reg;

endmodule