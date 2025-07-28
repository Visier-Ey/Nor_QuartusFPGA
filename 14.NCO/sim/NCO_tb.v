`timescale 1ns/1ps
module NCO_tb();

// 时钟和复位信号
reg sys_clk;
reg sys_rst_n;

// NCO输出信号
wire [7:0] da_data;
wire da_clk;

// 实例化NCO模块
NCO uut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .da_data(da_data),
    .da_clk(da_clk)
);

// 时钟生成（假设输入时钟50MHz）
initial begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk;  // 50MHz时钟周期20ns
end

// 复位信号控制
initial begin
    sys_rst_n = 0;  // 初始复位
    #100 sys_rst_n = 1;  // 100ns后释放复位
    // #5000 $finish;  // 仿真5us后结束
end

// // 监测关键信号
// initial begin
//     $monitor("Time=%0t: rst_n=%b, da_data=%h, da_clk=%b", 
//              $time, sys_rst_n, da_data, da_clk);
// end

// // 生成波形文件（VCD格式）
// initial begin
//     $dumpfile("nco_wave.vcd");
//     $dumpvars(0, nco_tb);
// end

endmodule