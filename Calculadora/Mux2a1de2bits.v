

module Mux2a1de2bits(A,B,OP,OUT);

    input [1:0] A,B;
    input OP;
    output reg [1:0] OUT;

    always @(OP or A or B)
        case (OP)
            1'b0: OUT=A;
            1'b1: OUT=B; 
        endcase

endmodule

