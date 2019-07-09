`timescale 1ns / 1ps

module WideXNOR(
		a, 
		w,
		x
    );

    parameter wide = 3 * 3 * 512;
	
    input [wide-1 : 0] a;
    input [wide-1 : 0] w;

    output [wide-1 : 0] x;

    // produces XNORs (result of binary multipliers)
    wire  [wide-1 : 0] x;
    assign x = a ~^ w;

endmodule
