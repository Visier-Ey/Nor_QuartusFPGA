`timescale 1ns/1ps

module NCO_tb;

// 测试参数
reg sys_clk;       // 50MHz 系统时钟
reg sys_rst_n;     // 系统复位(低电平有效)
wire [7:0] da_data; // NCO 输出数据

// 实例化被测模块
nco_t uut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .da_data(da_data)
);

// 生成 50MHz 时钟
initial begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk; // 50MHz (周期20ns)
end

// 复位控制和测试流程
initial begin
    // 初始化
    sys_rst_n = 0;
    
    // 释放复位
    #100 sys_rst_n = 1;
    
    // 运行足够长时间观察波形
    #500000; // 500us 仿真时间
    
    $display("Simulation finished");
    $finish;
end

// // 记录波形文件(用于查看波形)
// initial begin
//     $dumpfile("nco_wave.vcd");
//     $dumpvars(0, NCO_tb);
// end

// // 监控输出
// always @(posedge sys_clk) begin
//     if (sys_rst_n) begin
//         $display("Time: %t, DA Data: %d", $time, da_data);
//     end
// end

endmodule