module tpcurrent(
    input sys_clk50,
    input rsn_t,	//主板复位信号
	 input rx_data,//FPGA模块接收到的数据
	 inout drdy_n,
	 input command,
	 output  cs_n,
	 output  [15:0]adcdata,//读寄存器数据
	 output  r_n_w,
	 output  rest_n,
	 output  tx_data,//模块发送的信号
	 output  [15:0]o_fifo,//从fifo输出的信号,实际并不存在，用于仿真中观察实例输出
	 output dac_clk,
	 output reg [13:0] dac_data
);

wire mclk;
wire sys_clk100;
//wire [15:0]o_fifo;
wire rcn;
wire write_full;
wire write_empty;
wire [8:0]usedw;
wire wrreq;

assign dac_clk = mclk;

pll_clk100	u_pll_clk10 (
	.areset ( ~rsn_t ),
	.inclk0 ( sys_clk50 ),
	.c0 (sys_clk100),//100MHz
	.c1 (mclk)//10MHz
	);

	
//fifo	u_fifo (
//	.aclr ( ~rsn_t ),
//	.clock ( mclk),
//	.data ( adcdata ),
//	.rdreq (  ),
//	.wrreq ( wrreq ),
//	.empty (  ),
//	.full (  ),
//	.q ( o_fifo ),
//	.usedw (  )
//	);

AD7760 u_AD7760(
	.mclk(mclk),
	.drdy_n(drdy_n),//测试的时候用于模拟芯片产生的信号
	.i_rest_n(rsn_t),
	.command(command),
	.r_n_w(r_n_w),
	.cs_n(cs_n),
	.o_rest_n(rest_n),
	.adcdata(adcdata),
	.wrreq(wrreq)
	);

//qsys例化
//    niios_qsys u0 (
//        .clk_clk       (sys_clk100),       //   clk.clk
//        .reset_reset_n (rsn_t),  // reset.reset_n
//		  .uart_rxd      (rx_data),      //  uart.rxd
//        .uart_txd      (tx_data)       //      .txd
//    );






endmodule
