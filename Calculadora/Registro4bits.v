module Registro4bits(CLK,RST,D,Q);

    input CLK,RST;
    input [3:0] D;
    output reg [3:0] Q;

    always @(posedge CLK or posedge RST) 
        if(RST)
            Q=3'd0;
        else
            Q=D;

endmodule