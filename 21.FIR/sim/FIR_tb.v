`timescale 1ns/1ps

module FIR_tb;

// 测试参数
parameter CLK_PERIOD = 20;  // 50MHz时钟
parameter TEST_DURATION = 5000;  // 总测试时间
    parameter BIT_PERIOD = 10000; // 保持100kbps数据速率
// 信号声明
reg clk;
reg rst_n;
reg clk_en;
reg [7:0] fir_in;
wire [15:0] fir_out;
reg  data_in;

// 实例化被测FIR滤波器
FIR_T uut (
    .sys_clk(clk),
    .sys_rst_n(rst_n),
    .fir_in(fir_in),
    .fir_out(fir_out),
    .data_in(data_in)
);

// 时钟生成
initial begin
    clk = 0;
    rst_n = 0;  // 初始复位信号为高
    #(2*CLK_PERIOD) rst_n = 1;  // 复位信号低电平持续2个时钟周期
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    data_in = 0;
    wait(rst_n);
    
    // 发送测试序列：01010101
    repeat(10) begin
        data_in = 1;
        #BIT_PERIOD;
        data_in = 0;
        #BIT_PERIOD;
    end
    
    // 发送随机数据
    repeat(20) begin
        data_in = $random % 2;
        #BIT_PERIOD;
    end
end


endmodule