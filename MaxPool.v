`timescale 1ns / 1ps

module MaxPool (
		clk,
		reset,

		stream_in,
		stream_in_en,

		stream_out
	);
	
	parameter ch_out = 128;
	parameter k_s_maxpool = 2;
	parameter w_in = 32;

	input clk;
	input reset;

	input [ch_out-1 : 0] stream_in;
	input stream_in_en;

	output [ch_out-1 : 0] stream_out;
	
	wire [ch_out*k_s_maxpool*k_s_maxpool-1 : 0] parallel_out_flat;
	genvar gi;
	generate
  		for (gi = 0; gi < ch_out; gi = gi + 1) begin : MaxPoolBuffer

    		defparam RowBuffer_inst.k_s = k_s_maxpool;
    		defparam RowBuffer_inst.p_n_cols = w_in;
			RowBuffer RowBuffer_inst(
				.clk(clk),
				.reset(reset),

				.stream_in(stream_in[gi]),
				.stream_in_en(stream_in_en),

				.parallel_out(parallel_out_flat[(gi+1)*k_s_maxpool*k_s_maxpool - 1 : gi*k_s_maxpool*k_s_maxpool])
			);

			assign stream_out[gi] = |(parallel_out_flat[(gi+1)*k_s_maxpool*k_s_maxpool - 1 : gi*k_s_maxpool*k_s_maxpool]);

  		end
	endgenerate

endmodule
