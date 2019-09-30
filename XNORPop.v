//////////////////////////////////////////////////////////////////////////////////////////
// To use this module you should:
//	set the following parameters:
//		Majority_enable = 0/1
//		pop_size = in the case of (Majority_enable == 1), pop_size should be multiply of 3
//////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module XNORPop(
		a, 
		w,
		pop
    );
	
	parameter Majority_enable = 0; 
	parameter Majority_approximate = 0; 
	parameter Majority_M = 3;
	parameter Majority_M_log = $clog2(Majority_M);

	// 576 = 3 * 3 * 64
    parameter pop_size = 576;	
    parameter pad = ((Majority_enable) & (pop_size%Majority_M != 0))? (Majority_M-(pop_size%Majority_M)): 0;
    parameter pop_size_padded = pop_size + pad;
    parameter pop_size_log = $clog2(pop_size_padded);
    parameter maj_size = pop_size_padded / Majority_M;
    parameter maj_size_log = $clog2(maj_size);

    parameter result_size = (Majority_enable == 1)? maj_size_log : pop_size_log;

    input [pop_size-1 : 0] a;
    input [pop_size-1 : 0] w;

    output [result_size-1 : 0] pop;

    // produces XNORs (result of binary multipliers)
    wire  [pop_size-1 : 0] XNORs;
    assign XNORs = a ~^ w;
    
    wire [pop_size_padded-1 : 0] XNORs_padded;
    assign XNORs_padded = {{pad{1'b0}},{XNORs}};

    // produces majority outputs
    reg [maj_size-1 : 0] Majs;
    reg [Majority_M_log-1:0] sum [maj_size-1 : 0];
    reg [2:0] Majs_9apx_internal [maj_size-1 : 0];
    reg [1:0] Majs_7apx_internal [maj_size-1 : 0];
    reg Majs_5apx_internal [maj_size-1 : 0];
    integer i1, i2;
	always @(*) begin
		for(i1 = 0; i1 < maj_size; i1 = i1 + 1) begin
			sum[i1] = 0;

			if (Majority_approximate)begin
				if (Majority_M == 3)begin
					// there is no approximation in this case
					// maj(0,1,2)
					Majs[i1] = ((XNORs_padded[i1*3]&XNORs_padded[i1*3+1]) | (XNORs_padded[i1*3+1]&XNORs_padded[i1*3+2]) | (XNORs_padded[i1*3+2]&XNORs_padded[i1*3]));
				end 
				else if (Majority_M == 5) begin
					// the simplest one. 
					// maj(maj(0,1,2),3,4)
					Majs_5apx_internal[i1] = ((XNORs_padded[i1*5]&XNORs_padded[i1*5+1]) | (XNORs_padded[i1*5+1]&XNORs_padded[i1*5+2]) | (XNORs_padded[i1*5+2]&XNORs_padded[i1*5]));
					Majs[i1] = ((Majs_5apx_internal[i1]&XNORs_padded[i1*5+3]) | (XNORs_padded[i1*5+3]&XNORs_padded[i1*5+4]) | (XNORs_padded[i1*5+4]&Majs_5apx_internal[i1]));
				end
				else if (Majority_M == 7) begin
					// the simplest one. 
					// maj(maj(0,1,2),maj(3,4,5),6)
					Majs_7apx_internal[i1][0] = ((XNORs_padded[i1*7]&XNORs_padded[i1*7+1]) | (XNORs_padded[i1*7+1]&XNORs_padded[i1*7+2]) | (XNORs_padded[i1*7+2]&XNORs_padded[i1*7]));
					Majs_7apx_internal[i1][1] = ((XNORs_padded[i1*7+3]&XNORs_padded[i1*7+4]) | (XNORs_padded[i1*7+4]&XNORs_padded[i1*7+5]) | (XNORs_padded[i1*7+5]&XNORs_padded[i1*7+3]));
					Majs[i1] = ((Majs_7apx_internal[i1][0]&Majs_7apx_internal[i1][1]) | (Majs_7apx_internal[i1][1]&XNORs_padded[i1*7+6]) | (XNORs_padded[i1*7+6]&Majs_7apx_internal[i1][0]));
				end
				else if (Majority_M == 9) begin
					// two layers of Majority-3 circuits
					// maj(maj(0,1,2),maj(3,4,5),maj(6,7,8))
					Majs_9apx_internal[i1][0] = ((XNORs_padded[i1*9]&XNORs_padded[i1*9+1]) | (XNORs_padded[i1*9+1]&XNORs_padded[i1*9+2]) | (XNORs_padded[i1*9+2]&XNORs_padded[i1*9]));
					Majs_9apx_internal[i1][1] = ((XNORs_padded[i1*9+3]&XNORs_padded[i1*9+4]) | (XNORs_padded[i1*9+4]&XNORs_padded[i1*9+5]) | (XNORs_padded[i1*9+5]&XNORs_padded[i1*9+3]));
					Majs_9apx_internal[i1][2] = ((XNORs_padded[i1*9+6]&XNORs_padded[i1*9+7]) | (XNORs_padded[i1*9+7]&XNORs_padded[i1*9+8]) | (XNORs_padded[i1*9+8]&XNORs_padded[i1*9+6]));
					Majs[i1] = ((Majs_9apx_internal[i1][0]&Majs_9apx_internal[i1][1]) | (Majs_9apx_internal[i1][1]&Majs_9apx_internal[i1][2]) | (Majs_9apx_internal[i1][2]&Majs_9apx_internal[i1][0]));
				end
			end
			else begin
				for (i2 = 0; i2 < Majority_M; i2 = i2 + 1)begin
					sum[i1] = sum[i1] + XNORs_padded[(i1 * Majority_M) + i2];
				end
				Majs[i1] = (sum[i1] > ((Majority_M-1)/2))? 1'b1: 1'b0;
			end
		end
	end

    // produces majority outputs
    /*
    reg  [maj_size-1 : 0] Majs;
    integer i;
	always @(*) begin
		for(i = 0; i < maj_size; i = i + 1) begin
			Majs[i] = ((XNORs_padded[i*3]&XNORs_padded[i*3+1]) | (XNORs_padded[i*3+1]&XNORs_padded[i*3+2]) | (XNORs_padded[i*3+2]&XNORs_padded[i*3]));
		end
	end*/

	// produces pop count of XNORs
    reg [pop_size_log-1 : 0] pop_temp;
    integer k;
	always @(*) begin
		pop_temp = {pop_size_log{1'b0}};  
		for(k = 0; k < pop_size; k = k + 1) begin
			pop_temp = pop_temp + XNORs[k];
		end
	end
	
		// produces pop count of majority outputs
    integer j;
    reg [maj_size_log-1 : 0] majpop_temp;
	always @(*) begin
		majpop_temp = {maj_size_log{1'b0}};  
		for(j = 0; j < maj_size; j = j + 1) begin
			majpop_temp = majpop_temp + Majs[j];
		end
	end

	assign pop = (Majority_enable == 1) ? majpop_temp : pop_temp;

endmodule
