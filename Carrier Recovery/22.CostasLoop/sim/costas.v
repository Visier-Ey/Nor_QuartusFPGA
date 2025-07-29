`timescale 1ns/1ps

module costas_tb;

    reg sys_clk = 0;
    reg sys_rst_n = 0;

    always #10 sys_clk = ~sys_clk;  // 50MHz 原始时钟

    // 输入信号
    reg [7:0] ad_data;

    // 输出信号
    wire [7:0] da_data;
    wire da_clk;
    wire ad_clk;

    // DUT
    CostasTop dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .ad_data(ad_data),
        .da_data(da_data),
        .da_clk(da_clk),
        .ad_clk(ad_clk)
    );

    // 正弦输入信号模拟（100kHz 正弦，采样率 3.072MHz）
    real fs = 3_072_000.0;
    real fc = 100_000.0;
    real t = 0;
    real sample;

    // 通过 ad_clk 控制采样（系统工作在 clk_30m，即 ad_clk）
    always @(posedge dut.clk_30m) begin
        t = t + 1/fs;
        sample = $sin(2.0 * 3.1415926 * fc * t);
        ad_data <= 8'd128 + $rtoi(sample * 100);
    end

    // 仿真控制
    initial begin
        $display("=== Start CostasTop testbench ===");

        #100;               // 等待PLL锁定
        sys_rst_n = 1;

        #500000;            // 仿真一定时间
        $stop;
    end

endmodule
