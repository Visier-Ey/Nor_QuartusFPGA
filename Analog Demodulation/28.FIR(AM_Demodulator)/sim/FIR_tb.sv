`timescale 1ns / 1ps

module FIR_tb;

    // 信号定义
    reg sys_clk;
    reg sys_rst_n;
    reg signed [7:0] ad_data;   // 有符号8位输入
    wire [13:0] da_data;

    // 实例化 DUT
    FIR_T uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .ad_data(ad_data),
        .da_data(da_data)
    );

    // 时钟生成 (100MHz)
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk; // 10ns周期
    end

    // 测试波形参数
    integer i;
    real t;
    real Fs = 100_000_000.0;  // 采样率 100MHz
    real Fc = 5_000_000.0;    // 载波频率 5MHz
    real Fm = 10_000.0;       // 调制音频频率 10kHz
    real mod_index = 0.9;     // 调制度
    real carrier, mod, am, am_norm;

    // 输出到文件
    integer fout;
    initial fout = $fopen("fir_output.txt", "w");

    // 初始化 & 激励
    initial begin
        sys_rst_n = 0;
        ad_data = 0;

        #100;
        sys_rst_n = 1;

        for (i = 0; i < 100000; i = i + 1) begin  // 1ms模拟时间
            t = i / Fs;
            carrier = $sin(2 * 3.1415926 * Fc * t);
            mod = 1.0 + mod_index * $sin(2 * 3.1415926 * Fm * t);
            am = carrier * mod;

            // 归一化到[-1,1]，防止溢出
            am_norm = am / 1.9;

            // 转换为有符号8位
            ad_data = $rtoi(am_norm * 127);

            #10; // 10ns = 100MHz采样间隔
            $fdisplay(fout, "%d", da_data);
        end

        #1000;
        $fclose(fout);
        $stop;
    end

endmodule
