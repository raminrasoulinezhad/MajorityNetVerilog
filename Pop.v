//////////////////////////////////////////////////////////////////////////////////////////
// To use this module you should:
//	set the following parameters:
//		Majority_enable = 0/1
//		pop_size = in the case of (Majority_enable == 1), pop_size should be multiply of 3
//////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module Pop(
		a, 
		pop
    );
	
	parameter Majority_enable = 0;
	// 576 = 3 * 3 * 64
    parameter pop_size = 576;	
    
    parameter pop_size_log = $clog2(pop_size);
    parameter maj_size = pop_size / 3;
    parameter maj_size_log = $clog2(maj_size);

    parameter result_size = (Majority_enable == 1)? maj_size_log : pop_size_log;

    input [pop_size-1 : 0] a;

    output [result_size-1 : 0] pop;

	// produces pop count of a
    reg [pop_size_log-1 : 0] pop_temp;
    integer k;
	always @(*) begin
		pop_temp = {pop_size_log{1'b0}};  
		for(k = 0; k < pop_size; k = k + 1) begin
			pop_temp = pop_temp + a[k];
		end
	end

	// produces majority outputs
    reg  [maj_size-1 : 0] Majs;
    integer i;
	always @(*) begin
		for(i = 0; i < maj_size; i = i + 1) begin
			Majs[i] = ((a[i*3]&a[i*3+1]) | (a[i*3+1]&a[i*3+2]) | (a[i*3+2]&a[i*3]));
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

