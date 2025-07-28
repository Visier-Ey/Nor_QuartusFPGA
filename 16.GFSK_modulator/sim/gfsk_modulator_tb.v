`timescale 1ns/1ps
module gfsk_modulator_tb;

    // 时钟和复位信号
    reg sys_clk;
    reg sys_rst_n;
    
    // 输入输出信号
    reg data_in;
    wire [7:0] da_data;
    wire da_clk;
    
    // 修改后的测试参数
    parameter CLK_PERIOD = 20;  // 50MHz系统时钟（周期20ns）
    parameter BIT_PERIOD = 1000; // 保持1Mbps数据速率
    // 实例化被测模块
    gfsk_modulator uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .da_data(da_data),
        .da_clk(da_clk)
    );
    
    // 系统时钟生成（50MHz）
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
    
    // 测试数据生成（保持原逻辑）
    initial begin
        data_in = 0;
        wait(sys_rst_n);
        
        // 发送测试序列：01010101
        repeat(1000) begin
            data_in = 1;
            #BIT_PERIOD;
            data_in = 0;
            #BIT_PERIOD;
        end
        
        // 发送随机数据
        repeat(2000) begin
            data_in = $random % 2;
            #BIT_PERIOD;
        end
        
        // $stop;
    end
    
    // // 波形记录
    // initial begin
    //     $dumpfile("gfsk_modulator.vcd");
    //     $dumpvars(0, gfsk_modulator_tb);
    // end
    
    // // 实时监控
    // initial begin
    //     $timeformat(-9, 0, "ns", 6);
    //     $monitor("Time=%t | DataIn=%b | DA_Data=%h | DA_CLK=%b", 
    //             $time, data_in, da_data, da_clk);
    // end

endmodule