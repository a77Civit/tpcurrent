/*
AD7760 Control Module 
base on CSDN:https://blog.csdn.net/skybabi_/article/details/84103582
Date:2020-1-30
尝试开始做串口发送部分 
*/
//在顶层模块中调用·AD7760模块 
module AD7760(
		input mclk,      //12MHz,时钟周期??83.333纳秒
		input drdy_n,
		input command,
		input i_rest_n,
		output reg r_n_w,    //读写信号
		output reg cs_n,      //片选使能信??
		output reg o_rest_n,
		output reg[15:0]adcdata,
		//output reg[15:0]i_fifo
		output reg wrreq//初始给低
);


//初步使用CLDIV_n = 1 时钟一分频模式 ICLK=MCLK  输出数据以MCLK频率输出,控制寄存1要配置成0x0000
//配置AD7760 控制寄存器1 地址为：0x0001，默认0x001A
//控制寄存器2 地址为：0x0002，默认值0x009B，ICLK二分频，频率：ICLK = 1/2 MCLK
parameter CONTROL1_MOD_VALE = 16'h0000;
parameter CONTROL2_MOD_VALE = 16'h0022;
parameter CONTROL1_ADDRESS = 16'h0001;
parameter CONTROL2_ADDRESS = 16'h0002;
parameter MCLKFREQUENT = 10000000;//10MHz
parameter STATE0 =4'd0;//复位状态
parameter WRESET1 = 4'd1;
parameter WRESET2 = 4'd2;
parameter WRITECONTROL1_ADR = 4'd3;
parameter WRITECONTROL1_ADR_END =4'd4;
parameter WRITECONTROL1_VAL = 4'd5;
parameter WRITECONTROL1_VAL_END = 4'd6;
parameter WRITECONTROL2_ADR = 4'd7;
parameter WRITECONTROL2_ADR_END = 4'd8;
parameter WRITECONTROL2_VAL = 4'd9;
parameter WRITECONTROL2_VAL_END = 4'd10;
parameter WAIT_SIX_MCLK = 4'd11;
parameter COLLECT = 4'd12;
parameter WAIT_DRDY = 4'd13;

localparam TICK_INIT = 1/ (0.5*MCLKFREQUENT);//初始化为二分频，TICK周期为TMCLK的两倍

//所有的initial语句内的语句构成了一个initial块。initial块从仿真0时刻开始执行，在整个仿真过程中只执行一??


//使用状态机吗？??
reg [3:0]current_sta;/*synthesis noprune*/
reg [3:0]next_sta;/*synthesis noprune*/
reg [2:0]rest_cnt = 3'b0;/*synthesis noprune*/
reg [4:0]time_cnt = 5'b0;/*synthesis noprune*/ //创建打拍子的综合计时器
reg [2:0]drdy_cnt;
wire contro_set_flg;
wire wait_six_flg;
reg ready_data_flg;//数据读取万册完成后清零

//上电后就写寄存器，CLDVIV_N = 1；使ICLK = MCLK

initial
begin
current_sta = STATE0;
next_sta = WRESET1;
end

assign contro_set_flg = (time_cnt == 4'd8)?(1'b1):(1'b0);//清零需要通过将总计数器复位
assign wait_six_flg = (time_cnt == 4'd6)?(1'b1):(1'b0);

 

always@(posedge drdy_n)
begin
	if (drdy_cnt == 2'b01) begin
		ready_data_flg <= 2'b01;
		drdy_cnt <= 2'b0;
	end
	else
		drdy_cnt <= drdy_cnt + 2'b01;
end


//上电的默认的时候 ICLK周期是MCLK的两倍，频率是一半
//三段式状态机
//第一段同步时序描述状态机的转换转移这一事实
always@(posedge mclk or negedge i_rest_n)//尝试加上下降沿的cs？
begin
	if (!i_rest_n) begin
		current_sta <= STATE0;
		rest_cnt <= 3'b0;
		time_cnt <= 5'b0;
//强制异步复位清零
	end
 
	else

	begin
		if (current_sta != next_sta) begin
			current_sta <= next_sta;
			rest_cnt <= 3'b0;
			time_cnt <= 5'b0;
			//状态不一样才跳转否则保持
		end
	
		else
	//否则current不变，计数器继续计数。
			begin
				if ((current_sta != WRESET1)&&(current_sta != WRESET2)) begin
					time_cnt <= time_cnt + 5'b1;//现态为写寄存器和读数据才开始计数
				end 
					else
						begin
							rest_cnt <= rest_cnt + 3'b1;//复位状态做复位mclk技术
						end
			end
	end
end


//第二段组合逻辑描述状态转移条件
//rest_cnt的清零要在状态转化之后才能进行。
always@(*)
begin
	case(current_sta)

		WRESET1:
			begin 
				if (rest_cnt == 1) begin
					next_sta <= WRESET2;
				end
				else
					next_sta <= WRESET1;
			end
		WRESET2:
			begin
				if ((rest_cnt == 2)) begin//高电平至少保持两个时钟周期76543978
					next_sta <= WRITECONTROL1_ADR; 

				end
				else
					next_sta <= WRESET2;
			end
		STATE0:
			begin
				next_sta <= WRESET1;
			end
		WRITECONTROL1_ADR:
			begin
				if (contro_set_flg == 1) begin//持续4个ICLK周期 上电默认CKDIV = 0；二分频
					next_sta <= WRITECONTROL1_ADR_END;
				end
				else
					next_sta <= WRITECONTROL1_ADR;
			end
		WRITECONTROL1_ADR_END:
			begin 
				if (contro_set_flg == 1) begin//过度状态结束标志符
					next_sta <= WRITECONTROL1_VAL;
				end
				else
					next_sta <= WRITECONTROL1_ADR_END;
			end
		WRITECONTROL1_VAL:
			begin
				if (contro_set_flg == 1) //持续4个ICLK周期 上电默认CKDIV = 0；二分频
					next_sta <= WRITECONTROL1_VAL_END;
				else
					next_sta <= WRITECONTROL1_VAL_END;
			end
		WRITECONTROL1_VAL_END:
		begin
			if (contro_set_flg == 1) //过度状态结束标志符
				next_sta <= WRITECONTROL2_ADR;
			else
				next_sta <= WRITECONTROL1_VAL_END;
		end
		WRITECONTROL2_ADR:
		begin
			if (contro_set_flg == 1) //持续4个ICLK周期 上电默认CKDIV = 0；二分频
				next_sta <= WRITECONTROL2_ADR_END;
			else
				next_sta <= WRITECONTROL2_ADR;
		end
		WRITECONTROL2_ADR_END:
		begin
			if (contro_set_flg == 1) //过度状态结束标志符
				next_sta <= WRITECONTROL2_VAL;
			else
				next_sta <= WRITECONTROL2_ADR_END;
		end
		WRITECONTROL2_VAL:
		begin
			if (contro_set_flg == 1) //持续4个ICLK周期 上电默认CKDIV = 0；二分频
				next_sta <= WRITECONTROL2_VAL_END;
			else
				next_sta <= WRITECONTROL2_VAL;
		end
		WRITECONTROL2_VAL_END:
		begin
			if((wait_six_flg == 1'b1)&&(command == 1'b1))//过度状态结束标志符
				next_sta <= COLLECT;//此状态过后配置完成，ICLK = MCLK
			else
			next_sta <= WRITECONTROL2_VAL_END;
		end
		COLLECT:
			if(!drdy_n)begin//下降沿跳到准备读取状态等待上升沿
				next_sta <= WAIT_DRDY;
			end else begin
				next_sta <= COLLECT;
			end//高电平跳转collect 给FIFO输出写入信号锁存adcdata

		WAIT_DRDY:
			if(drdy_n)begin//drdy跳高之后数据有效了，跳转COLLECT
				next_sta <= COLLECT;
			end else begin
				next_sta <= WAIT_DRDY;
			end//高电平跳转collect 给FIFO输出写入信号锁存adcdata

		default:
			next_sta <= STATE0;
	endcase
	end

//第三段描各个状态的输出//drdy部分另外一个模块写
always@(*)begin

case(current_sta)
	STATE0:
		begin
			o_rest_n <= 1'b1;
			cs_n <= 1'b1;
			r_n_w <= 1'b1;
			adcdata <= 16'd0;
		end
	WRESET1:
		cs_n <= 1'b0;
	WRESET2:
		cs_n <= 1'b1;//延时到了拉高复位信号线要保持两个时钟周期
	
	WRITECONTROL1_ADR:
	begin
		adcdata <= CONTROL1_ADDRESS;
		cs_n <= 1'b0;
	end
	WRITECONTROL1_ADR_END:
	begin
		
		cs_n <= 1'b1;
	end	
	WRITECONTROL1_VAL:
	begin
		adcdata <= CONTROL1_MOD_VALE;
		cs_n <= 1'b0;
	end
	WRITECONTROL1_VAL_END:
	begin
		
		cs_n <= 1'b1;
	end
	WRITECONTROL2_ADR:
	begin
		adcdata <= CONTROL2_ADDRESS;
		cs_n <= 1'b0;
	end
	WRITECONTROL2_ADR_END:
	begin
		
		cs_n <= 1'b1;
	end
	WRITECONTROL2_VAL:
	begin
		adcdata <= CONTROL2_MOD_VALE;
		cs_n <= 1'b0;
	end
	WRITECONTROL2_VAL_END:
	begin
		
		cs_n <= 1'b1;//最后写完后拉高之后等待至少六个MCLK，退出写模式？
	end
	COLLECT:
	begin
		r_n_w <= 1'b0;//先拉低cs和读写信号，等待drdy信号号再读取输出数据
		cs_n <= 1'b0;
		if (command == 1) begin
			//i_fifo <= adcdata;
			wrreq <= 1'b1;
		end
		else
			//i_fifo <= 16'b0;
			wrreq <= 1'b0;
	end

	WAIT_DRDY:
	begin
		wrreq <= 1'b0;
	end

	default:
		begin
			o_rest_n <= 1'b1;
			cs_n <= 1'b1;
			r_n_w <= 1'b1;
			adcdata <= 16'd0;
		end
endcase

end

endmodule