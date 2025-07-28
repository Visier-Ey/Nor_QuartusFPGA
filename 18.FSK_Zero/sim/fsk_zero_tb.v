`timescale 1ns / 1ps
module fsk_zero_tb();
    reg sys_clk;
    reg sys_rst_n;
    
    // 输入输出信号
    reg data_in;
    wire [7:0] da_data;
    wire da_clk;
    wire demodulated_bit;

   FSK_Zero uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .da_data(da_data),
        .demodulated_bit(demodulated_bit)
    );

      // 修改后的测试参数
    parameter CLK_PERIOD = 20;  // 50MHz系统时钟（周期20ns）
    parameter BIT_PERIOD = 10000; // 保持100kbps数据速率

    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk; // 每10ns翻转一次
    end
    
    // 复位控制（保持不变）
    initial begin
        sys_rst_n = 0;
        #100; // 复位持续时间100ns
        sys_rst_n = 1;
    end

    initial begin
        data_in = 0;
        wait(sys_rst_n);
        
        // 发送测试序列：01010101
        repeat(10000) begin
            data_in = 1;
            #BIT_PERIOD;
            data_in = 0;
            #BIT_PERIOD;
        end
        
        // 发送随机数据
        repeat(20000) begin
            data_in = $random % 2;
            #BIT_PERIOD;
        end
    
    // $stop;
    end

    initial begin
    // 等待特定条件或时间
        #10000; // 等待1000ns
        // $finish;
    end
endmodule