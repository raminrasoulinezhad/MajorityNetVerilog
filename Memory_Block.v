`timescale 1ns / 1ps

module Memory_Block(
		clk, 
		
		w_enable,
		w_addr,
		w_data,

		r_addr,
		r_data
    );

	parameter width = 32;
	parameter length = 10;
	parameter addr_size = $clog2(length);

	input clk;

	input w_enable;
	input [addr_size-1:0] w_addr;
	input [width-1:0] w_data;

	input [addr_size-1:0] r_addr;
	output [width-1:0] r_data;

	(* ram_style = "block" *) reg [width-1 : 0] mem [length-1 : 0];

	always @(posedge clk) begin
		if (w_enable) begin
			mem[w_addr] <= w_data;
		end
	end

	assign r_data = mem[r_addr];
	
endmodule
