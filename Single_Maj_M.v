`timescale 1ns / 1ps
module Single_Maj_M(
    	a,
    	m
    );
	
	parameter M = 3;
	parameter M_log2 = $clog2(M);

	input [M-1:0] a;
	
	output m;

	reg [M_log2-1:0] sum;
	integer i;
	always @(*) begin
		sum = 0;
		for (i = 0; i < M; i = i + 1)begin
			sum = sum + a[i];
		end
	end

    assign m =  (sum > ((M-1)/2))? 1'b1: 1'b0;
 
endmodule
