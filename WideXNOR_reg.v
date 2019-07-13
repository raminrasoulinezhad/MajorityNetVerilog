`timescale 1ns / 1ps

module WideXNOR_reg(
		clk,
		reset,

		a, 
		w,
		x
    );

    parameter wide = 3 * 3 * 8;

    input clk;
    input reset;

    input a;
    input w;
	
	reg [wide-1 : 0] a_reg;
	reg [wide-1 : 0] w_reg;

    output reg [wide-1 : 0] x;

	always @ (posedge clk) begin
		a_reg <= {{a_reg[wide-2 : 0]},{a}};
		w_reg <= {{w_reg[wide-2 : 0]},{w}};
	end

	wire [wide-1 : 0] x_temp;
	defparam WideXNOR_inst.wide = wide;
	WideXNOR 	WideXNOR_inst(
		.a(a_reg),
		.w(w_reg),
		.x(x_temp)
	);	

	always @ (posedge clk) begin
		x <= x_temp;
	end

endmodule
