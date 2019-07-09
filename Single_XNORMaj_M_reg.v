`timescale 1ns / 1ps
module Single_XNORMaj_M_reg(
		clk,
    	
    	a,
    	w,
    	
    	m
    );
	
	parameter M = 9;

	input clk;
	input [M-1:0] a;
	input [M-1:0] w;
	
	output reg m;

	reg [M-1:0] a_reg;
	reg [M-1:0] w_reg;
	always @ (posedge clk) begin
		a_reg <= a; 
		w_reg <= w; 
		m <= m_temp;
	end

	wire m_temp;
	defparam Single_XNORMaj_M_inst.M = M;
	Single_XNORMaj_M 	Single_XNORMaj_M_inst(
    	.a(a_reg),
    	.w(w_reg),
    	.m(m_temp)
    );
    
endmodule
