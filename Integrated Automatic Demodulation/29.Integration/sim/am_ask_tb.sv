`timescale 1ns / 1ps

module am_ask_tb;

    // ===================== 用户可修改参数 =====================
    parameter CLK_FREQ      = 50_000_000;    // 系统时钟50MHz
    parameter SAMP_FREQ     = 100_000_000;   // 采样率100MHz
    parameter CARRIER_FREQ  = 20_000_000;    // 载波20MHz
    parameter BASEBAND_FREQ = 10_000;        // 基带10kHz
    parameter MOD_DEPTH     = 1.0;           // 调制深度(0~1)
    parameter INPUT_AMPLITUDE = 127;         // 输入幅度(8位有符号)
    parameter SIM_DURATION  = 800_000;       // 仿真800us
    // ========================================================

    // 系统信号
    reg sys_clk;
    reg sys_rst_n;
    
    // 数据接口
    reg signed [7:0] ad_data;   // 有符号8位输入
    wire [7:0] da_data;         // 8位输出

    // 被测模块实例
    Integration uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),  
        .d_in(ad_data),
        .mode_select(2'b00),    // AM模式
        .d_out(da_data),
        .status_led()
    );

    // 50MHz时钟生成（20ns周期）
    initial begin
        sys_clk = 0;
        forever #(1e9/CLK_FREQ/2) sys_clk = ~sys_clk;
    end

    // 信号生成变量
    integer i;
    real t;
    real carrier, baseband, am_signal, am_norm;

    // 采样间隔（100MHz = 10ns）
    real samp_step = 1e9/SAMP_FREQ;

    initial begin
        // 初始化
        sys_rst_n = 0;
        ad_data = 0;
        
        // 复位释放
        #100 sys_rst_n = 1;

        // 主信号生成循环（按100MHz步进）
        for (i = 0; i < SIM_DURATION/10; i = i + 1) begin
            t = i * (1.0/SAMP_FREQ);  // 时间按100MHz计算
            
            // 1. 生成基带信号 (10kHz正弦)
            baseband = $sin(2 * 3.1415926 * BASEBAND_FREQ * t);
            
            // 2. 生成载波信号 (20MHz正弦)
            carrier = $sin(2 * 3.1415926 * CARRIER_FREQ * t);
            
            // 3. AM调制公式: (1 + m*baseband) * carrier
            am_signal = (1.0 + MOD_DEPTH * baseband) * carrier;
            
            // 4. 归一化防止超幅
            am_norm = am_signal / (1.0 + MOD_DEPTH);
            
            // 5. 转换为8位有符号
            ad_data = $rtoi(am_norm * INPUT_AMPLITUDE);
            
            // 6. 等待下一个采样点（10ns @100MHz）
            #(samp_step);
        end

        #1000 $stop;
    end

endmodule