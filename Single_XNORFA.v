`timescale 1ns / 1ps
module Single_XNORFA(
    	input [2:0] a,
    	input [2:0] w,
    	output [1:0] m
    );

	wire [2:0] x;
	assign x = a ~^ w;
    assign m = x[2] + x[1] + x[0];
 
endmodule
