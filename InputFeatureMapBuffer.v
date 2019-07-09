`timescale 1ns / 1ps

module InputFeatureMapBuffer (
		clk,
		reset,

		stream_act,
		stream_act_en,

		parallel_out_flat
	);
	
	parameter ch_in = 128;
	parameter k_s = 3;
	parameter w_in = 32;
	parameter pad = 1;

	input clk;
	input reset;

	input [ch_in-1 : 0] stream_act;
	input stream_act_en;

	output [ch_in*k_s*k_s-1 : 0] parallel_out_flat;
	
	genvar gi;
	generate
  		for (gi = 0; gi < ch_in; gi = gi + 1) begin : InputBuffer

    		defparam RowBuffer_inst.k_s = k_s;
    		defparam RowBuffer_inst.p_n_cols = pad + w_in + pad;
			RowBuffer RowBuffer_inst(
				.clk(clk),
				.reset(reset),

				.stream_in(stream_act[gi]),
				.stream_in_en(stream_act_en),

				.parallel_out(parallel_out_flat[(gi+1)*k_s*k_s - 1 : gi*k_s*k_s])
			);

  		end
	endgenerate

endmodule
