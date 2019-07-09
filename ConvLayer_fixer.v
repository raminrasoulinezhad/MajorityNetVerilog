// Convlayer is modified a lot and it needs modification.
`timescale 1ns / 1ps

module ConvLayer_fixer (
		clk,
		reset,

		stream_in_add,
		stream_in_en,

		stream_w_add,
		stream_w_en,

		stream_out_xor
	);
	
	parameter Majority_enable = 0;
	parameter ch_out = 128;

	parameter ch_in = 128;
	parameter k_s = 3;
	parameter w_in = 32;
	parameter pad = 1;

	parameter result_width = Majority_enable? $clog2(ch_in*k_s) : $clog2(ch_in*k_s*k_s);

	parameter stream_w_add_width = $clog2(ch_in*k_s*k_s);
	parameter stream_in_add_width = $clog2(ch_in);

	input clk;
	input reset;

	input [stream_in_add_width-1 : 0] stream_in_add;
	input stream_in_en;

	input [stream_w_add_width-1 : 0] stream_w_add;
	input stream_w_en;
	
	output [ch_out-1 : 0] stream_out_xor;

	// weight streamer
	reg [ch_in*k_s*k_s-1 : 0] stream_w;
	always @ (*) begin
		stream_w = {stream_w_add_width{1'b0}};
		stream_w[stream_w_add] = stream_w_en;
	end

	// input streamer
	reg [ch_in-1 : 0] stream_in;
	always @ (*) begin
		stream_in = {stream_in_add_width{1'b0}};
		stream_in[stream_in_add] = stream_in_en;
	end
	

	defparam ConvLayer_inst.Majority_enable = Majority_enable;
	defparam ConvLayer_inst.ch_out = ch_out;
	defparam ConvLayer_inst.ch_in = ch_in;
	defparam ConvLayer_inst.k_s = k_s;
	defparam ConvLayer_inst.pad = pad;
	ConvLayer ConvLayer_inst(
		.clk(clk),
		.reset(reset),

		.stream_in(stream_in),
		.stream_in_en(stream_in_en),
		.stream_w(stream_w),
		.stream_w_en(stream_w_en),

		.stream_out(stream_out_xor)
	);

	

endmodule

