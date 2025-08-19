`timescale 1ns / 1ps

module fm_tb;
    // ===================== 用户可修改参数 =====================
    parameter CLK_FREQ   = 50_000_000;   // 系统时钟50MHz
    parameter SAMP_FREQ  = 100_000_000;  // 实际采样率100MHz
    parameter CARRIER_FREQ  = 1e6;       // 载波1MHz
    parameter FM_DEVIATION  = 50e3;      // 频偏50kHz
    parameter BASEBAND_FREQ = 15e3;      // 基带15kHz
    parameter INPUT_AMPLITUDE = 127;     // 输入幅度
    parameter SIM_DURATION = 1_000_000;  // 仿真1ms
    // ========================================================

    // 时钟与复位
    reg clk = 0;
    reg rst_n = 0;

    // DUT接口
    reg signed [7:0] fm_in;
    wire signed [15:0] demod_out;

    Integration uut (
        .sys_clk(clk),
        .sys_rst_n(rst_n),
        .d_in(fm_in),
        .mode_select(2'b10),
        .d_out(demod_out),
        .status_led()
    );

    // 50MHz时钟生成
    always #(1e9/CLK_FREQ/2) clk = ~clk;

    // 信号生成变量
    real t = 0;
    real phase = 0;
    real baseband, modulated;
    real demod_scaled;

    // 采样间隔计算（100MHz采样率对应的步长）
    real samp_step = 1e9/SAMP_FREQ; // 10ns

    // 双时钟域处理（50MHz→100MHz）
    reg [1:0] samp_phase = 0;
    always @(posedge clk) begin
        samp_phase <= samp_phase + 1;
    end

    initial begin
        #20 rst_n = 1;
        
        forever begin
            // 基带信号生成（时间按100MHz步进）
            baseband = $sin(2.0 * 3.1415926 * BASEBAND_FREQ * t*1e-9);
            
            // FM调制
            phase = phase + 2.0 * 3.1415926 * 
                   (CARRIER_FREQ + FM_DEVIATION * baseband) * 
                   (samp_step*1e-9);
                   
            modulated = $cos(phase);
            
            // 每个系统时钟周期生成2个样本（50MHz→100MHz）
            if(samp_phase[0]) begin
                fm_in = $rtoi(INPUT_AMPLITUDE * modulated);
            end
            
            demod_scaled = demod_out / 65536.0;
            
            // 按100MHz步进
            #(samp_step);
            t = t + samp_step;
        end
    end

    initial #SIM_DURATION $finish;
endmodule