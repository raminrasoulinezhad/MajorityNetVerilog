`timescale 1ns / 1ps
module Single_XNORFA_reg(
		input clk,
    	input [2:0] a,
    	input [2:0] w,
    	output reg [1:0] m
    );
	
	reg [2:0] a_reg;
	reg [2:0] w_reg;
	always @ (posedge clk) begin
		a_reg <= a; 
		w_reg <= w; 
		m <= m_temp;
	end

	wire [1:0] m_temp;
	Single_XNORFA 	Single_XNORFA_inst(
    	.a(a_reg),
    	.w(w_reg),
    	.m(m_temp)
    );
    
endmodule
