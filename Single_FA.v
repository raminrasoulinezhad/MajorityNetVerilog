`timescale 1ns / 1ps
module Single_FA(
    	input [2:0] a,
    	output [1:0] m
    );

    assign m = a[2] + a[1] + a[0];
 
endmodule
