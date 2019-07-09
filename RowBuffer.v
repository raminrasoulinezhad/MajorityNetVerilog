`timescale 1ns / 1ps

module RowBuffer (
		clk,
		reset,

		stream_in,
		stream_in_en,

		parallel_out
	);
	
	parameter k_s = 3;
	// input size + required pads =  1 + 32 + 1 = 34
	parameter p_n_cols = 34;

	parameter p_n_rows = k_s;				
	parameter p_n_buffer = (p_n_rows-1) * p_n_cols + k_s;

	input clk;
	input reset;

	input stream_in;
	input stream_in_en;

	output reg [(k_s*k_s)-1:0] parallel_out;

	// shift register implementation
	reg [p_n_buffer-1:0] buffer;
	always @ (posedge clk) begin
		if  (reset) begin
			buffer <= {p_n_buffer{1'b0}};
		end
		else if (stream_in_en) begin
			buffer <= {{buffer[p_n_buffer-2:0]},{stream_in}};
		end
	end

	// mapping the output
	integer j, k;
	always @ (*) begin
		for (j = 0; j < k_s; j = j + 1) begin
			for (k = 0; k < k_s; k = k + 1) begin
				parallel_out[j*k_s+k] = buffer[(k_s-1-j)*p_n_cols + k_s - 1 - k];
			end
		end
	end
endmodule
