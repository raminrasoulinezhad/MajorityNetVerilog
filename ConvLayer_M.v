`timescale 1ns / 1ps

module ConvLayer_M (
		clk,
		reset,

		fold_addr,

		stream_act,
		stream_act_en,

		stream_w_singlebit,
		stream_w_singlebit_en,
		stream_w_en,
		stream_w_addr,
		
		stream_th_singlebit,
		stream_th_singlebit_en,
		stream_th_en,
		stream_th_addr,

		stream_maxpool_en,				

		stream_out
	);

	parameter Majority_enable = 0;
	parameter fold = 1;
	parameter fold_log = (fold == 1)? 1 : $clog2(fold);

	parameter ch_out = 64;
	parameter ch_out_fold = ch_out/fold;

	parameter ch_in = 64;
	parameter w_in = 32;

	parameter k_s = 3;
	parameter pad = 1;

	parameter MAXPOOL_enable = 1;
	parameter k_s_maxpool = 2;

	parameter result_width = Majority_enable? $clog2(ch_in*k_s) : $clog2(ch_in*k_s*k_s);
	parameter pop_size = k_s*k_s*ch_in;

	parameter stream_w_size = (fold == 1) ?  (ch_in*k_s*k_s) : (ch_in*k_s*k_s*ch_out_fold);
	parameter stream_th_size = (fold == 1) ?  (result_width) : (result_width*ch_out_fold);

	input clk;
	input reset;

	input [fold_log-1:0] fold_addr;

	input [ch_in-1 : 0] stream_act;
	input stream_act_en;

	input stream_w_singlebit;
	input stream_w_singlebit_en;
	input stream_w_en;
	input [fold_log-1:0] stream_w_addr;
	
	input stream_th_singlebit;
	input stream_th_singlebit_en;
	input stream_th_en;
	input [fold_log-1:0] stream_th_addr;

	input stream_maxpool_en;
	output [ch_out-1 : 0] stream_out;

	reg [stream_w_size-1 : 0] stream_w_sr;
	always @ (posedge clk)begin
		if (reset) begin
			stream_w_sr <= {stream_w_size{1'b0}};
		end
		else if (stream_w_singlebit_en) begin
			stream_w_sr <= {{stream_w_sr[stream_w_size-2:0]},{stream_w_singlebit}};
		end
	end

	reg [stream_th_size-1 : 0] stream_th_sr;
	always @ (posedge clk)begin
		if (reset) begin
			stream_th_sr <= {stream_th_size{1'b0}};
		end
		else if (stream_th_singlebit_en) begin
			stream_th_sr <= {{stream_th_sr[stream_th_size-2:0]},{stream_th_singlebit}};
		end
	end

	defparam ConvLayer_inst.Majority_enable = Majority_enable;
	defparam ConvLayer_inst.fold = fold;
	defparam ConvLayer_inst.ch_out = ch_out;
	defparam ConvLayer_inst.ch_in = ch_in;
	defparam ConvLayer_inst.w_in = w_in;
	defparam ConvLayer_inst.k_s = k_s;
	defparam ConvLayer_inst.pad = pad;
	defparam ConvLayer_inst.MAXPOOL_enable = MAXPOOL_enable;
	defparam ConvLayer_inst.k_s_maxpool = k_s_maxpool;
	ConvLayer	ConvLayer_inst (
		.clk(clk),
		.reset(reset),

		.fold_addr(fold_addr),

		.stream_act(stream_act),
		.stream_act_en(stream_act_en),

		.stream_w(stream_w_sr),
		.stream_w_en(stream_w_en),
		.stream_w_addr(stream_w_addr),
		
		.stream_th(stream_th_sr),
		.stream_th_en(stream_th_en),
		.stream_th_addr(stream_th_addr),

		.stream_maxpool_en(stream_maxpool_en),				

		.stream_out(stream_out)
	);

endmodule
