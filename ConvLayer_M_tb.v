`timescale 1ns / 1ps

module ConvLayer_M_tb ();
	
	parameter Majority_enable = 0;
	parameter fold = 1;
	parameter fold_log = (fold == 1)? 1 : $clog2(fold);

	parameter ch_out = 64;
	parameter ch_out_fold = ch_out/fold;

	parameter ch_in = 64;
	parameter w_in = 32;

	parameter k_s = 3;
	parameter pad = 1;

	parameter MAXPOOL_enable = 0; //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	parameter k_s_maxpool = 2;

	parameter result_width = Majority_enable? $clog2(ch_in*k_s) : $clog2(ch_in*k_s*k_s);
	parameter pop_size = k_s*k_s*ch_in;

	parameter stream_w_size = (fold == 1) ?  (ch_in*k_s*k_s) : (ch_in*k_s*k_s*ch_out_fold);
	parameter stream_th_size = (fold == 1) ?  (result_width) : (result_width*ch_out_fold);
	parameter stream_depth = (fold == 1) ?  ch_out : fold;

	reg clk;
	initial begin
		clk = 1'b0;
		forever begin
			#5 clk = ~clk;
		end
	end
	reg reset;

	reg [fold_log-1:0] fold_addr;
	
	reg [ch_in-1 : 0] stream_act;
	reg stream_act_en;

	reg stream_w_singlebit;
	reg stream_w_singlebit_en;
	reg stream_w_en;
	reg [fold_log-1:0] stream_w_addr;

	reg stream_th_singlebit;
	reg stream_th_singlebit_en;
	reg stream_th_en;
	reg [fold_log-1:0] stream_th_addr;
	
	reg stream_maxpool_en;

	initial
	begin
		fold_addr = {fold_log{1'b0}};
		stream_act = {ch_in{1'b0}};
		stream_act_en = 1'b0;

		stream_w_singlebit = 1'b0;
		stream_w_singlebit_en = 1'b0;
		stream_w_en = 1'b0;
		stream_w_addr = {fold_log{1'b0}};

		stream_th_singlebit = 1'b0;
		stream_th_singlebit_en = 1'b0;
		stream_th_en = 1'b0;
		stream_th_addr = {fold_log{1'b0}};

		stream_maxpool_en = 1'b0;
	end

	wire [ch_out-1 : 0] stream_out;

	defparam ConvLayer_M_inst.Majority_enable = Majority_enable;
	defparam ConvLayer_M_inst.fold = fold;
	defparam ConvLayer_M_inst.ch_out = ch_out;
	defparam ConvLayer_M_inst.ch_in = ch_in;
	defparam ConvLayer_M_inst.w_in = w_in;
	defparam ConvLayer_M_inst.k_s = k_s;
	defparam ConvLayer_M_inst.pad = pad;
	defparam ConvLayer_M_inst.MAXPOOL_enable = MAXPOOL_enable;
	defparam ConvLayer_M_inst.k_s_maxpool = k_s_maxpool;
	ConvLayer_M 	ConvLayer_M_inst(
		.clk(clk),
		.reset(reset),

		.fold_addr(fold_addr),

		.stream_act,
		.stream_act_en,

		.stream_w_singlebit(stream_w_singlebit),
		.stream_w_singlebit_en(stream_w_singlebit_en),
		.stream_w_en(stream_w_en),
		.stream_w_addr(stream_w_addr),
		
		.stream_th_singlebit(stream_th_singlebit),
		.stream_th_singlebit_en(stream_th_singlebit_en),
		.stream_th_en(stream_th_en),
		.stream_th_addr(stream_th_addr),

		.stream_maxpool_en(stream_maxpool_en),				

		.stream_out(stream_out)
	);

	reg [ch_in*k_s*k_s-1:0] w [ch_out-1:0];
	reg [ch_in*k_s*k_s-1:0] w_temp;
	reg [result_width-1:0] th [ch_out-1:0]; 
	reg [result_width-1:0] th_temp; 
	integer i, j;
	integer file_w, file_th;
	initial
	begin
		file_w = $fopen("w.txt","r");
		file_th = $fopen("t.txt","r");
		
		for (i = 0; i < ch_out; i = i + 1) begin 
	        $fscanf(file_w,"%b\n",w_temp);
	        $fscanf(file_th,"%b\n",th_temp);
	        w[i] = w_temp;
	        th[i] = th_temp;	    	
	    end 

		reset = 1'b1;
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		reset = 1'b0;
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)

		// load Weights
		for (i = ch_out-1; i >= 0; i = i - 1) begin 		
			for (j = ch_in*k_s*k_s-1; j >= 0; j = j - 1) begin 
				@(posedge clk)
				stream_w_en = 1'b0;
				stream_w_singlebit = w[i][j];
				stream_w_singlebit_en = 1'b1;
			end
			@(posedge clk)
			stream_w_singlebit_en = 1'b0;
			stream_w_en = 1'b1;
		end
		@(posedge clk)
		stream_w_en = 1'b0;

		// load Threshold
		for (i = ch_out-1; i >= 0; i = i - 1) begin 		
			for (j = result_width-1; j >= 0; j = j - 1) begin 
				@(posedge clk)
				stream_th_en = 1'b0;
				stream_th_singlebit = th[i][j];
				stream_th_singlebit_en = 1'b1;
			end
			@(posedge clk)
			stream_th_singlebit_en = 1'b0;
			stream_th_en = 1'b1;
		end
		@(posedge clk)
		stream_th_en = 1'b0;

		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)

		for (i = 0; i < ((k_s-1)*(pad+w_in+pad)+k_s); i = i + 1) begin
			@(posedge clk)
			stream_act = {ch_in{1'b1}};
			stream_act_en = 1'b1;
		end
		@(posedge clk)
		stream_act = {ch_in{1'b0}};
		@(posedge clk)
		stream_act = {ch_in{1'b0}};
		stream_act_en = 1'b0;

		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)
		@(posedge clk)





		$stop;
	end


endmodule
