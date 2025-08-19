`timescale 1ns/1ps

module Integration_tb;

    // 测试参数
    parameter CLK_PERIOD = 20;  // 50MHz时钟周期
    
    // 测试信号
    reg sys_clk;
    reg sys_rst_n;
    reg [7:0] data_in;
    reg data_valid;
    reg [1:0] mode_select;
    reg [31:0] phi_inc;
    
    wire [15:0] data_out;
    wire data_out_valid;
    wire [2:0] status_led;
    wire locked;
    
    // 实例化被测模块
    Integration uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .data_valid(data_valid),
        .mode_select(mode_select),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .status_led(status_led)
    );
    
    // 时钟生成
    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    end
    
    // 测试序列
    initial begin
        // 初始化
        sys_rst_n = 0;
        data_in = 8'h00;
        data_valid = 0;
        mode_select = 2'b00;
        
        // 等待PLL锁定
        #(CLK_PERIOD * 100);
        sys_rst_n = 1;
        
        // 等待PLL锁定
        wait(locked);
        $display("PLL locked at time %t", $time);
        
        // 测试AM模式
        $display("Testing AM mode...");
        mode_select = 2'b00;
        #(CLK_PERIOD * 10);
        
        // 发送测试数据
        for (int i = 0; i < 10; i++) begin
            data_in = 8'h40 + i;  // 测试数据
            data_valid = 1;
            #(CLK_PERIOD);
            data_valid = 0;
            #(CLK_PERIOD * 9);
        end
        
        // 测试BPSK模式
        $display("Testing BPSK mode...");
        mode_select = 2'b01;
        phi_inc = 32'h0000_1000;  // 设置NCO频率
        #(CLK_PERIOD * 10);
        
        // 发送测试数据
        for (int i = 0; i < 10; i++) begin
            data_in = 8'h80 + i;  // 测试数据
            data_valid = 1;
            #(CLK_PERIOD);
            data_valid = 0;
            #(CLK_PERIOD * 9);
        end
        
        // 测试FM模式
        $display("Testing FM mode...");
        mode_select = 2'b10;
        phi_inc = 32'h0000_2000;  // 设置NCO频率
        #(CLK_PERIOD * 10);
        
        // 发送测试数据
        for (int i = 0; i < 10; i++) begin
            data_in = 8'hC0 + i;  // 测试数据
            data_valid = 1;
            #(CLK_PERIOD);
            data_valid = 0;
            #(CLK_PERIOD * 9);
        end
        
        // 测试无效模式
        $display("Testing invalid mode...");
        mode_select = 2'b11;
        #(CLK_PERIOD * 20);
        
        // 完成测试
        $display("All tests completed at time %t", $time);
        $finish;
    end
    
    // 监控输出
    always @(posedge sys_clk) begin
        if (data_out_valid) begin
            $display("Time: %t, Mode: %b, Data In: %h, Data Out: %h, Status: %b", 
                     $time, mode_select, data_in, data_out, status_led);
        end
    end
    
    // 超时保护
    initial begin
        #(CLK_PERIOD * 10000);  // 10us超时
        $display("Simulation timeout!");
        $finish;
    end

endmodule 