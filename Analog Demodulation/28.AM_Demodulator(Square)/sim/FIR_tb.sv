`timescale 1ns / 1ps

module FIR_tb;

    reg sys_clk;
    reg sys_rst_n;
    reg signed [7:0] ad_data;   // 有符号8位输入
    wire [7:0] da_data;        // 输出位宽调整下

    // DUT 实例
    FIR_T uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .ad_data(ad_data),
        .da_data(da_data)
    );

    // 时钟生成 (100 MHz)
    initial begin
        sys_clk = 0;
        forever #5 sys_clk = ~sys_clk; // 10 ns 周期
    end

    integer i;
    real t;
    real Fs = 100_000_000.0;   // 采样率 100 MHz
    real Fc = 20_000_000.0;    // 载波频率 20 MHz
    real Fm = 10000.0;          // 基带频率 1 kHz（模拟低频调制信号）
    real modulation_depth = 1; // 调制深度(0~1)
    real carrier, baseband_signal, am_signal, am_norm;

    initial begin
        sys_rst_n = 0;
        ad_data = 0;

        #100;
        sys_rst_n = 1;

        for (i = 0; i < 80000; i = i + 1) begin
            t = i / Fs;

            // 基带模拟信号：1 kHz 正弦波，范围 [-1,1]
            baseband_signal = $sin(2 * 3.1415926 * Fm * t);

            // 载波信号
            carrier = $sin(2 * 3.1415926 * Fc * t);

            // AM 调制： (1 + m * 基带) * 载波
            am_signal = (1.0 + modulation_depth * baseband_signal) * carrier;

            // 归一化，防止超幅
            am_norm = am_signal / (1.0 + modulation_depth);

            // 转换为有符号 8 位
            ad_data = $rtoi(am_norm * 127);

            #10; // 采样周期 10ns (100 MHz)
        end

        #1000;
        $stop;
    end

endmodule
