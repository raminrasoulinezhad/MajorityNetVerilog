//////////////////////////////////////////////////////////////////////////////////////////
// This module is designed to measure the maximum frequency of Popounter module
//
// To use this module you should:
//	set the following parameters:
//		Majority_enable = 0/1
//		pop_size = in the case of (Majority_enable == 1), pop_size should be multiply of 3
//////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module Pop_reg(
		clk,
		reset,

		a, 
		pop
    );

    parameter Majority_enable = 0;
    // 576 = 3 * 3 * 64
    parameter pop_size = 576;		
    parameter maj_size = pop_size / 3;
    parameter result_size_normal = $clog2(pop_size);
    parameter result_size_majority = $clog2(maj_size);
    parameter result_size = (Majority_enable == 1)? result_size_majority : result_size_normal;

    input clk;
    input reset;

    input a;
	
	reg [pop_size-1 : 0] a_reg;

    output reg [result_size-1 : 0] pop;

	always @ (posedge clk) begin
		a_reg <= {{a_reg[pop_size-2 : 0]},{a}};
	end

	wire [result_size-1 : 0] pop_temp;
	defparam Pop_inst.Majority_enable = Majority_enable;
	defparam Pop_inst.pop_size = pop_size;
	Pop 	Pop_inst(
		.a(a_reg),
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
