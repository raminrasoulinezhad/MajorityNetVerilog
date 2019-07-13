`timescale 1ns / 1ps

module FCLayer (
		clk,
		reset,

		fold_addr,

		stream_act,
		stream_act_en,

		stream_w,
		stream_w_en,
		stream_w_addr,

		stream_th,
		stream_th_en,	
		stream_th_addr,

		stream_out
	);

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
	input stream_act_en;
	
	input [stream_w_size-1 : 0] stream_w;
	input stream_w_en;
	input [fold_log-1:0] stream_w_addr;
	
	input [stream_th_size-1 : 0] stream_th;
	input stream_th_en;
	input [fold_log-1:0] stream_th_addr;

	output reg [ch_out-1 : 0] stream_out;

	// input 
	reg [ch_in-1 : 0] buffer_parallel_out_flat;
	always @(posedge clk) begin
		if (reset)begin
			buffer_parallel_out_flat <= {ch_in{1'b0}};
		end
		else if (stream_act_en) begin
			buffer_parallel_out_flat <= stream_act;
		end
	end

	// Weights
	reg [ch_in-1 : 0] w_dist [ch_out-1 : 0];
	integer i;
	always @ (posedge clk) begin
		if (stream_w_en) begin 
			w_dist[0] <= stream_w;
			for (i = 1; i < ch_out; i = i + 1) begin
				w_dist[i] <= w_dist[i-1];
			end
		end
	end
	wire [stream_w_size-1 : 0] w_flat;
	defparam Memory_Block_inst_w.width = stream_w_size;
	defparam Memory_Block_inst_w.length = fold;
	Memory_Block	Memory_Block_inst_w(
		.clk(clk), 
		
		.w_enable(stream_w_en),
		.w_addr(stream_w_addr),
		.w_data(stream_w),

		.r_addr(fold_addr),
		.r_data(w_flat)
    );
    reg [ch_in-1 : 0] w [ch_out_fold-1 : 0];
    integer i_w, i_w_2;
    always @(*)begin
    	if (fold != 1) begin 
	    	for (i_w = 0; i_w < ch_out_fold; i_w = i_w + 1) begin
	    		for (i_w_2 = 0; i_w_2 < ch_in; i_w_2 = i_w_2 + 1) begin
	    			w[i_w][i_w_2] = w_flat[i_w*ch_in+i_w_2];
	    		end
	    	end
	    end else begin
	    	for (i_w = 0; i_w < ch_out; i_w = i_w + 1) begin
				w[i_w] = w_dist[i_w];
			end
	    end
    end

	// Thrshold
	reg [result_width-1 : 0] Threshold_dist [ch_out-1 : 0];
	integer k;
	always @ (posedge clk) begin
		if (stream_th_en) begin 
			Threshold_dist[0] <= stream_th;
			for (k = 1; k < ch_out; k = k + 1) begin
				Threshold_dist[k] <= Threshold_dist[k-1];
			end
		end
	end
	wire [stream_th_size-1 : 0] th_flat;
	defparam Memory_Block_inst_th.width = stream_th_size;
	defparam Memory_Block_inst_th.length = fold;
	Memory_Block	Memory_Block_inst_th(
		.clk(clk), 
		
		.w_enable(stream_th_en),
		.w_addr(stream_th_addr),
		.w_data(stream_th),

		.r_addr(fold_addr),
		.r_data(th_flat)
    );
	reg [result_width-1 : 0] Threshold [ch_out_fold-1 : 0];
    integer i_t, i_t_2;
    always @(*)begin
    	if (fold != 1) begin
	    	for (i_t = 0; i_t < ch_out_fold; i_t = i_t + 1) begin
	    		for (i_t_2 = 0; i_t_2 < result_width; i_t_2 = i_t_2 + 1) begin
	    			Threshold[i_t][i_t_2] = th_flat[i_t*result_width+i_t_2];
	    		end
	    	end
	    end else begin
	    	for (i_t = 0; i_t < ch_out; i_t = i_t + 1) begin
				Threshold[i_t] = Threshold_dist[i_t];
			end
	    end
    end

	// PE implementations
	wire [result_width-1 : 0] pop_out [ch_out_fold-1 : 0];
    genvar gi;
	generate
  		for (gi = 0; gi < ch_out_fold; gi = gi + 1) begin : genbit
			defparam Pop_inst.Majority_enable = Majority_enable;
			defparam Pop_inst.pop_size = pop_size;
    		XNORPop Pop_inst(
				.a(buffer_parallel_out_flat), 
				.w(w[gi]),
				.pop(pop_out[gi])
			);
  		end
	endgenerate

	reg [ch_out_fold-1 : 0] stream_thresh;
	integer j;
	always @(*) begin
		for(j = 0; j < ch_out_fold; j = j + 1) begin
			stream_thresh[j] = (pop_out[j] > Threshold[j]) ? 1'b1: 1'b0;
		end
	end

	integer i_s;
	always @(posedge clk) begin
		if(reset) begin
			stream_out <= {ch_out{1'b0}};
		end
		else begin
			if (fold != 1) begin 
				for (i_s = 0; i_s < ch_out_fold; i_s = i_s + 1) begin
					stream_out[fold_addr*ch_out_fold + i_s] <= stream_thresh[i_s];
				end
			end 
			else begin
				stream_out <= stream_thresh;
			end
		end
	end

endmodule
