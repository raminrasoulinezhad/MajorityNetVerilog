//////////////////////////////////////////////////////////////////////////////////////////
// This module is designed to measure the maximum frequency of XnorPopcounting module
//
// To use this module you should:
//	set the following parameters:
//		Majority_enable = 0/1
//		Majority_M = 3/5/7/9
//////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module XNORPop_reg(
		clk,
		reset,

		a, 
		w,
		pop
    );

    parameter Majority_enable = 0;
    parameter Majority_M = 3;
    // 576 = 3 * 3 * 64
    parameter pop_size = 576;	
    parameter maj_size = pop_size / Majority_M;
    parameter result_size_normal = $clog2(pop_size);
    parameter result_size_majority = $clog2(maj_size);
    parameter result_size = (Majority_enable == 1)? result_size_majority : result_size_normal;

    input clk;
    input reset;

    input a;
    input w;

    output reg [result_size-1 : 0] pop;

	reg [pop_size-1 : 0] a_reg;
	reg [pop_size-1 : 0] w_reg;
	always @ (posedge clk) begin
		a_reg <= {{a_reg[pop_size-2 : 0]},{a}};
		w_reg <= {{w_reg[pop_size-2 : 0]},{w}};
	end

	wire [result_size-1 : 0] pop_temp;
	defparam XNORPop_inst.Majority_enable = Majority_enable;
	defparam XNORPop_inst.pop_size = pop_size;
	defparam XNORPop_inst.Majority_M = Majority_M;
	XNORPop 	XNORPop_inst(
		.a(a_reg),
		.w(w_reg),
		.pop(pop_temp)
	);	

	always @ (posedge clk) begin
		if (reset)begin
			pop <= {result_size{1'b0}};
		end
		else begin
			pop <= pop_temp;
		end
	end

endmodule
