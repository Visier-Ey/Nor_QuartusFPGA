`timescale 1ns/1ps

module tb_fm_demod;

    //============================ 信号定义 ============================//
    reg         sys_clk;
    reg         sys_rst_n;

    wire [7:0]  ad_data;
    wire        ad_clk, ad_otr;
    wire [7:0]  da_data;
    wire        da_clk;
    wire [15:0] filter;
    wire        clk_150m;
    //============================ DUT 实例 ============================//
    fm_demod dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .ad_data(ad_data),
        .ad_otr(ad_otr),
        .ad_clk(ad_clk),
        .da_clk(da_clk),
        .da_data(da_data)
    );

    //============================ 时钟与复位 ============================//
    initial sys_clk = 0;
    always #10 sys_clk = ~sys_clk;  // 50MHz 时钟

    initial begin
        sys_rst_n = 0;
        #200;
        sys_rst_n = 1;
    end

    //============================ FM信号生成 ============================//
    real t = 0;
    real fc = 1e6;      // 载波频率 1MHz
    real fm = 1e4;      // 音频频率 10kHz
    real fs = 30e6;     // 采样频率 30MHz
    real freq_dev = 5e4;// 调频偏移
    real baseband;      // 调制前音频信号
    real inst_phase;
    real carrier;

    reg [7:0] ad_data_reg;
    assign ad_data = ad_data_reg;
    assign ad_otr = 1'b0;

    always @(posedge ad_clk) begin
        t = t + 1.0/fs;

        baseband = $sin(2.0 * 3.1415926 * fm * t); // ⭐️ 基带信号
        inst_phase = 2.0 * 3.1415926 * (fc * t + (freq_dev / fm) * baseband);
        carrier = $sin(inst_phase);

        ad_data_reg <= 128 + $rtoi(carrier * 50.0);  // 载波映射到 8-bit
    end

    //============================ 仿真波形输出 ============================//

    // 波形转储文件 (支持 GTKWave)
    // initial begin
    //     $dumpfile("fm_demod_tb.vcd");
    //     $dumpvars(0, tb_fm_demod);
    // end

    // // 实时输出基带信号和DA结果
    // always @(posedge ad_clk) begin
    //     $display("t=%.6fus | baseband=%.3f | da_data=%0d",
    //              t*1e6, baseband, da_data);
    // end

    //============================ 仿真结束控制 ============================//
    initial begin
        #5_000_000; // 仿真 5ms
        $finish;
    end

endmodule
