`timescale 1ns / 1ps

module fm_demod_tb;

    // 时钟与复位
    reg clk = 0;
    reg rst_n = 0;

    // DUT接口
    reg signed [7:0] fm_in;
    reg [31:0] phi_inc = 32'd0;
    wire signed [15:0] demod_out;
    wire [7:0] nco_sin, nco_cos;
    wire [15:0] I_out, Q_out;
    wire [15:0] I_mix, Q_mix;
    wire [31:0] port;
    wire signed [15:0] I_prev, Q_prev;
    wire signed [15:0] I_in, Q_in;

    // 被测模块实例
    fm_demod uut (
        .clk(clk),
        .rst_n(rst_n),  
        .fm_in(fm_in),
        .phi_inc(phi_inc),
        .demod_out(demod_out),
        .nco_sin(nco_sin),
        .nco_cos(nco_cos),
        .I(I_out),
        .Q(Q_out),
        .I_mix(I_mix),
        .Q_mix(Q_mix),
        .port(port),
        .I_prev(I_prev),
        .Q_prev(Q_prev),
        .I_in(I_in),
        .Q_in(Q_in)
    );

    // 时钟生成：100MHz (10ns周期)
    always #5 clk = ~clk;

    // 实数信号参数
    real t = 0;
    real fc = 1e6;      // 1MHz载波
    real fs = 100e6;    // 100MHz采样率
    real kf = 20e3;      // 频偏系数500kHz
    real fm = 15e3;      // 1kHz基带
    real phase = 0;     // 相位累加器

    // 波形跟踪变量
    real baseband_track, fm_modulated_track, demod_out_track;

    initial begin
        // 波形记录
        $dumpfile("fm_demod_tb.vcd");
        $dumpvars(0, fm_demod_tb);

        // 复位
        #20 rst_n = 1;
        
        // 设置NCO频率（1MHz）
        phi_inc = 32'd42_949_673;  // 1e6 * 2^32 / 100e6

        // 主仿真循环
        forever begin
            // 1. 生成基带信号（1kHz正弦）
            baseband_track = $sin(2.0 * 3.1415926 * fm * t);
            
            // 2. FM调制（积分求相位）
            phase = phase + 2.0 * 3.1415926 * (fc + kf * baseband_track) * (1.0/fs);
            
            // 3. 生成调制信号（8位有符号）
            fm_modulated_track = $cos(phase);
            fm_in = $rtoi(127.0 * fm_modulated_track);
            
            // 4. 解调输出归一化（用于波形观察）
            demod_out_track = demod_out / 65536.0;
            
            // 5. 时间步进（同步时钟）
            @(posedge clk);
            t = t + 10e-9;  // 10ns步长
        end
    end

    // 仿真结束
    initial begin
        #1000000 $finish;  // 仿真2ms
    end

endmodule