module AM_ASK (
    input clk,
    input rst_n,
    input [7:0]  d_in,
    output [7:0]  d_out
);

    wire signed [7:0] fir_in;
    wire signed [13:0] fir_out;
    wire signed [15:0] signal_squared;
    assign signal_squared = fir_in * fir_in;
    // FIR滤波器实例化
    A_FIR a_fir_inst (
        .clk(clk),
        .fir_in(fir_in > 0 ? fir_in : -fir_in), // 处理负数输入
        .fir_out(fir_out)
    );

    assign fir_in = d_in; 

    // 输出连接
    assign d_out = fir_out; 

endmodule