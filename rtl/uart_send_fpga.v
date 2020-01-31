/*
用新起点开发板
*/
module uart_tr(
	input clk,
	input rst_n,
	input [7:0]tx_datain,//并行总线如发送模块
	output reg tx_data, //并行转串行按位发出去
	output reg done
);
parameter BAUDRATE = 9600;//默认波特率
parameter FREQUENCE = 50_000_000;//使用50Hz时钟
localparam TIME_OF_BIT = FREQUENCE / BAUDRATE; 
//UART use a posedge as start-signal
wire tx_cnt;
wire time_cnt;



endmodule