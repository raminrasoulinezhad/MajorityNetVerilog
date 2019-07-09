`timescale 1ns / 1ps
	
// This module is a compact of 3 XNOR and a majority-3 circuit in a 6-input LUT
// synthesied using Vivado into a LUT6

module XNORMajority222(
    	input [2:0] a,
    	input [2:0] w,
    	output m
    );
    wire [2:0] XNORs;

    assign XNORs[0] = a[0] ~^ w[0];
    assign XNORs[1] = a[1] ~^ w[1];
    assign XNORs[2] = a[2] ~^ w[2];

    assign m = ((XNORs[0]&XNORs[1]) | (XNORs[1]&XNORs[2]) | (XNORs[2]&XNORs[0]));

endmodule
