`timescale 1ns / 1ps
module Single_FA_reg(
		input clk,
    	input [2:0] a,
    	output reg [1:0] m
    );
	
	reg [2:0] a_reg;
	always @ (posedge clk) begin
		a_reg <= a; 
		m <= m_temp;
	end

	wire [1:0] m_temp;
	Single_FA 	Single_FA_inst(
    	.a(a_reg),
    	.m(m_temp)
    );
    
endmodule
