`timescale 1ns / 1ps

/** Convolutional Layer L1:
 *      IFM  =    30  IFM_CH =    64
 *      OFM  =    28  OFM_CH =    64
 *     SIMD  =    32    PE   =    32
 *     WMEM  =    36   TMEM  =     2
 *     #Ops  = 57802752   Ext Latency  = 28224 **/

module FINN_PE(
		clk, 
		reset,

		stream_WMEM,
		enable_w,
		stream_TMEM,
		enable_t,

		input_vector,
		index_WMEM,
		index_TMEM,

		add_enable,

		output_vector
    );

	parameter Majority_enable = 0;
	parameter ratio = (Majority_enable == 1) ? 1 : 1;

	parameter k_s = 3;

	// parameter IFM = 30;
	parameter IFM_CH = 64;
	// parameter OFM = 28;
	// parameter OFM_CH = 64;
	parameter SIMD = 32 * ratio;
	// parameter PE = 32;

	parameter WMEM = 36 / ratio;
	parameter TMEM = 2;

	parameter index_WMEM_size = $clog2(WMEM);
	parameter index_TMEM_size = $clog2(TMEM);
	parameter width_WMEM = SIMD;
	parameter result_size_normal = $clog2(IFM_CH * k_s * k_s);
    parameter result_size_majority = $clog2(IFM_CH * k_s);
    parameter result_size = (Majority_enable == 1)? result_size_majority : result_size_normal;
	parameter width_TMEM = result_size;

	parameter pop_size_normal = $clog2(SIMD);
    parameter pop_size_majority = $clog2(SIMD/3);
    parameter pop_size = (Majority_enable == 1)? pop_size_majority : pop_size_normal;

	input clk;
	input reset;

	input [width_WMEM-1 : 0] stream_WMEM;
	input enable_w;
	input [width_TMEM-1 : 0] stream_TMEM;
	input enable_t;

	input [SIMD-1 : 0] input_vector;
	input [index_WMEM_size-1 : 0] index_WMEM;
	input [index_TMEM_size-1 : 0] index_TMEM;

	input add_enable;

	output output_vector;

	// weight memory
	wire [width_WMEM-1 : 0] Mem_w_out;
	defparam Mem_w.width = width_WMEM;
	defparam Mem_w.length = WMEM;
	Memory_serial_load 	Mem_w(
		.clk(clk),
		.reset(reset),
		.enable(enable_w), 

		.stream(stream_WMEM),
		.addr(index_WMEM),

		.out(Mem_w_out)
    );

	// Threshold memories
	wire [width_TMEM-1 : 0] Mem_t_out;
	defparam Mem_t.width = width_TMEM;
	defparam Mem_t.length = TMEM;
    Memory_serial_load 	Mem_t(
		.clk(clk), 
		.reset(reset),
		.enable(enable_t),

		.stream(stream_TMEM),
		.addr(index_TMEM),

		.out(Mem_t_out)
    );


    // normal pop counter 
    wire [pop_size_normal-1 : 0] XNORPop_pop;
	defparam XNORPop_inst.pop_size = SIMD;
	XNORPop 	XNORPop_inst(
		.a(input_vector),
		.w(Mem_w_out),
		.pop(XNORPop_pop)
	);	
	
	// majority pop counter 
	wire [pop_size_majority-1 : 0] XNORMajorityPop_pop;
	defparam XNORMajorityPop_inst.pop_size = SIMD;
	XNORMajorityPop 	XNORMajorityPop_inst(
		.a(input_vector),
		.w(Mem_w_out),
		.pop(XNORMajorityPop_pop)
	);

	wire [pop_size-1 : 0] pop;
	assign pop = (Majority_enable == 1)? XNORMajorityPop_pop: XNORPop_pop;

	reg [result_size-1 : 0] accumulator;
	always @ (posedge clk) begin
		if (add_enable)
			accumulator <= pop;
		else
			accumulator <= accumulator + pop;
	end

	// applying threshold on answers
	assign output_vector = ((accumulator + pop) > Mem_t_out)? 1'b1: 1'b0;

endmodule
