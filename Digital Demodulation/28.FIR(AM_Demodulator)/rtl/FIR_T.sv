module FIR_T (
    input sys_clk,
    input sys_rst_n,
    input [7:0]  ad_data,
    output [13:0]  da_data
);

    wire clk;
    wire signed [7:0] fir_in;
    wire signed [13:0] fir_out;
    wire signed [15:0] signal_squared;
    assign signal_squared = fir_in * fir_in;
    // FIR滤波器实例化
    FIR fir_inst (
        .clk(clk),
        .fir_in(signal_squared),
        .fir_out(fir_out)
    );

    // 时钟和复位逻辑
    assign clk = sys_clk; // 假设sys_clk是FIR模块的时钟输入
    assign fir_in = ad_data; // 假设da_data是FIR模块的输入

    // 输出连接
    assign da_data = fir_out; // 假设ad_data是FIR模块的输出

endmodule