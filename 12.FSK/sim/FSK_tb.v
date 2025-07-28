`timescale 1ns/1ps

module FSK_tb();

// 输入信号
reg sys_clk;
reg sys_rst_n;
reg opt;

// 输出信号
wire [7:0] da_data;
wire da_clk;

// 时钟参数
localparam CLK_100M_PERIOD = 10;  // 100MHz时钟周期10ns
localparam CLK_10M_PERIOD = 100;   // 10MHz时钟周期100ns

// 实例化被测模块
top_FSK u_top_FSK (
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .opt        (opt),
    .da_data    (da_data),
    .da_clk     (da_clk)
);

// 生成系统时钟
initial begin
    sys_clk = 0;
    forever #(CLK_100M_PERIOD/2) sys_clk = ~sys_clk;
end

// 测试激励
initial begin
    // 初始化
    sys_rst_n = 0;
    opt = 0;
    
    // 复位
    #100;
    sys_rst_n = 1;
    
    // 测试FSK模式A
    $display("Testing FSK mode A (opt=0)");
    opt = 0;
    #2000;
    
    // 测试FSK模式B
    $display("Testing FSK mode B (opt=1)");
    opt = 1;
    #2000;
    
    // 测试模式切换
    $display("Testing mode switching");
    repeat (5) begin
        opt = ~opt;
        #10000;
    end
    
    // // 结束仿真
    // $display("Simulation finished");
    // $finish;
end

// // 监控输出
// initial begin
//     $timeformat(-9, 2, " ns", 10);
//     $monitor("At time %t: opt = %b, da_data = %b, da_clk = %b", 
//              $time, opt, da_data, da_clk);
// end

// // 生成波形文件（根据仿真工具可能需要调整）
// initial begin
//     $dumpfile("tb_top_FSK.vcd");
//     $dumpvars(0, tb_top_FSK);
// end

endmodule