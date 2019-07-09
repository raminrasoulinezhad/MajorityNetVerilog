`timescale 1ns / 1ps

module ORGate(
    	in,
        out
    );
    
    parameter k_s = 2;

    input [k_s*k_s-1 : 0] in;
    output out;

    assign out = |in;

endmodule
