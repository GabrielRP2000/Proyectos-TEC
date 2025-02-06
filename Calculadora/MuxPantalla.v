
module MuxPantalla(A,B,S,OUT);

    input [3:0] A,B;
    input S;
    output reg [3:0] OUT;

    always @(A or B or S)
        case (S)
            1'b1: OUT=A;
            1'b0: OUT=B; 
        endcase
endmodule


