module AD_DA(
    input           sys_clk,
    input           sys_rst_n,
    //ad
    input  [7:0]    ad_data,    //读取八位ad数据
    input           ad_otr,
    output          ad_clk,         //AD(AD9280)驱动时钟,最大支持32Mhz时钟 
    output          test_clk,
    //da
    output          da_clk,    //DA(AD9708)驱动时钟,最大支持125Mhz时钟
    output [7:0]    da_data    //给DA的数据
);
wire clk_30M;       // 30MHz时钟，用于系统逻辑和ADC
assign test_clk = clk_30M;
wire pll_locked;     // PLL锁定信号
my_pll_ip u_My_pll (
    .areset         (~sys_rst_n),
    .inclk0         (sys_clk),
    .c0             (clk_30M),
    .locked         (pll_locked)
);
 wire system_rst_n = sys_rst_n & pll_locked;

assign da_clk = ~clk_30M;
assign ad_clk = clk_30M;
wire ad_sample_ce;
//AD_read u_AD_read(
//    .clk     (sys_clk),
//    .rst_n   (sys_rst_n),
//    .ad_data (ad_data),
//    .ad_clk  (ad_clk),
//    .ad_ce   (ad_sample_ce)
//    );

// 捕获ADC数据
reg [7:0] adc_data_regged;
always @(posedge clk_30M or negedge system_rst_n) begin
    if (!system_rst_n)
        adc_data_regged <= 0;
    else
        adc_data_regged <= ad_data; // 每个时钟周期都锁存
end
wire signed [7:0] FM_in;
assign      FM_in = adc_data_regged - 128;//无符号变符号

reg         [7:0] buffer;
wire        [7:0] data_out1; //微分后数据
reg         [7:0] data_out2;//ABS后数据
assign      data_out1=FM_in-buffer;

wire signed [10:0] data_out1_amplified; // 放大后需要更多位宽以防溢出
reg         [7:0]  data_out2_final;     // 送给FIR的最终数据

//--------------------------微分（累减）--------------------------------------------//
always @(posedge clk_30M   or negedge system_rst_n) begin
	if(!system_rst_n) begin
		buffer <= 0;
	end
	else begin
        buffer <= FM_in;
	end
end
assign data_out1_amplified = data_out1 <<< 4; 
//--------------------------取绝对值-----------------------------------------//

always @(posedge sys_clk) begin
    if(data_out1[7] == 1)    begin
        data_out2 <= -{data_out1};        //如果符号位是1，对数据取反
    end
    else if(data_out1[7] == 0)    begin
        data_out2 <= data_out1;           //如果符号位是0，数据不变
    end
    else    begin
        data_out2 <= data_out2;
    end
end	 
//
wire signed [19:0]  FIRout;
wire                fir_output_valid;
fir_ip_core u_my_fir(
	.clk                (clk_30M ),
	.reset_n            (system_rst_n),
	.ast_sink_data      (data_out2),
	.ast_sink_valid     (1'b1),
	.ast_source_ready   (1'b1),
	.ast_sink_error     (2'b00),
	.ast_source_data    (FIRout),
	.ast_sink_ready     (),
	.ast_source_valid   (fir_output_valid),
	.ast_source_error   ()
    );
wire signed [7:0] dac_out;
assign dac_out = FIRout[16:9];//改到下面幅值变大了
//assign dac_out = FIRout[12:5];
assign da_data = dac_out+128 ;
endmodule