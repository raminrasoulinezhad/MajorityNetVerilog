`timescale 1ns / 1ps
module Single_Maj_M_reg(
		clk,
    	
    	a,
    	
    	m
    );
	
	parameter M = 3;
	
	input clk;
	input [M-1:0] a;
	
	output reg m;

	reg [M-1:0] a_reg;
	always @ (posedge clk) begin
		a_reg <= a; 
		m <= m_temp;
	end

	wire m_temp;
	defparam Single_Maj_M_inst.M = M;
	Single_Maj_M 	Single_Maj_M_inst(
    	.a(a_reg),
    	.m(m_temp)
    );
    
endmodule
