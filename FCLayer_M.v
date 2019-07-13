`timescale 1ns / 1ps

module FCLayer_M (
		clk,
		reset,

		fold_addr,

		stream_act,
		stream_act_singlebit,
		stream_act_singlebit_en,
		stream_act_en,

		stream_w_singlebit,
		stream_w_singlebit_en,
		stream_w_en,
		stream_w_addr,

		stream_th_singlebit,
		stream_th_singlebit_en,
		stream_th_en,	
		stream_th_addr,

		stream_out
	);
	
	parameter Input_serial_en = 1;

	parameter Majority_enable = 0;
	parameter fold = 64;
	parameter fold_log = (fold == 1)? 1 : $clog2(fold);

	parameter ch_out = 512;							
	parameter ch_out_fold = ch_out/fold;
	// if (Majority_enable == 1) ==> dividable by 3
	parameter ch_in = 4096; 							

	parameter result_width = (Majority_enable == 1)? $clog2(ch_in/3) : $clog2(ch_in);
	parameter pop_size = ch_in;

	parameter stream_w_size = (fold == 1) ?  (ch_in) : (ch_in*ch_out_fold);
	parameter stream_th_size = (fold == 1) ?  (result_width) : (result_width*ch_out_fold);

	input clk;
	input reset;

	input [fold_log-1:0] fold_addr;

	input [ch_in-1 : 0] stream_act;
	input stream_act_singlebit;
	input stream_act_singlebit_en;
	input stream_act_en;
	
	input stream_w_singlebit;
	input stream_w_singlebit_en;
	input stream_w_en;
	input [fold_log-1:0] stream_w_addr;
	
	input stream_th_singlebit;
	input stream_th_singlebit_en;
	input stream_th_en;
	input [fold_log-1:0] stream_th_addr;

	output [ch_out-1 : 0] stream_out;

	reg [ch_in-1 : 0] stream_act_sr;
	always @ (posedge clk) begin
		if (reset) begin
			stream_act_sr <= {ch_in{1'b0}};
		end 
		else if (stream_act_singlebit_en) begin
			stream_act_sr <= {{stream_act_sr[ch_in-2:0]},{stream_act_singlebit}};
		end

	end
	assign stream_act_temp = (Input_serial_en == 1)? stream_act_sr: stream_act;

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

	defparam FCLayer_inst.Majority_enable = Majority_enable;
	defparam FCLayer_inst.fold = fold;
	defparam FCLayer_inst.ch_out = ch_out;
	defparam FCLayer_inst.ch_in = ch_in;
	FCLayer	FCLayer_inst(
		.clk(clk),
		.reset(reset),

		.fold_addr(fold_addr),

		.stream_act(stream_act_temp),
		.stream_act_en(stream_act_en),

		.stream_w(stream_w_sr),
		.stream_w_en(stream_w_en),
		.stream_w_addr(stream_w_addr),

		.stream_th(stream_th_sr),
		.stream_th_en(stream_th_en),	
		.stream_th_addr(stream_th_addr),

		.stream_out(stream_out)
	);

endmodule
