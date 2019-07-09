`timescale 1ns / 1ps

module Memory_serial_load(
		clk, 
		reset,
		enable,

		stream,
		addr,

		out
    );

	parameter width = 32;
	parameter length = 10;
	parameter addr_size = $clog2(length);

	input clk;
	input reset;
	input enable;

	input [width-1 : 0] stream;
	input [addr_size-1 : 0] addr;

	output [width-1 : 0] out;

	reg [width-1 : 0] mem [length-1 : 0];

	integer i;
	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < length; i = i + 1)begin
				mem[i] <= {width{1'b0}};
			end
		end
		else if (enable) begin 
			mem[0] <= stream;
			for (i = 1; i < length; i = i + 1)begin
				mem[i] <= mem[i-1];
			end
		end
	end

	assign out = mem[addr];
	
endmodule
