// 15阶有符号FIR滤波器
// 截止频率=0.002π，输入=8位，输出=8位
module FIR (
    input clk,
    input signed [7:0] fir_in,
    output signed [7:0] fir_out
);
    reg signed [7:0] delay_line [0:14];

    // 量化系数（自动处理负数）
    localparam signed [16:0] coeff0 = 17'sd5241;
    localparam signed [16:0] coeff1 = 17'sd8226;
    localparam signed [16:0] coeff2 = 17'sd16590;
    localparam signed [16:0] coeff3 = 17'sd28678;
    localparam signed [16:0] coeff4 = 17'sd42095;
    localparam signed [16:0] coeff5 = 17'sd54183;
    localparam signed [16:0] coeff6 = 17'sd62549;
    localparam signed [16:0] coeff7 = 17'sd65535;

    always @(posedge clk) begin
        integer i;
        for (i = 14; i > 0; i = i - 1)
            delay_line[i] <= delay_line[i-1];
        delay_line[0] <= fir_in;
    end

    wire signed [24:0] product0, product1, product2, product3, product4, product5, product6, product7;
    assign product0 = (delay_line[0] + delay_line[14]) * coeff0;
    assign product1 = (delay_line[1] + delay_line[13]) * coeff1;
    assign product2 = (delay_line[2] + delay_line[12]) * coeff2;
    assign product3 = (delay_line[3] + delay_line[11]) * coeff3;
    assign product4 = (delay_line[4] + delay_line[10]) * coeff4;
    assign product5 = (delay_line[5] + delay_line[9]) * coeff5;
    assign product6 = (delay_line[6] + delay_line[8]) * coeff6;
    assign product7 = delay_line[7] * coeff7;

    wire signed [28:0] sum = product0 + product1 + product2 + product3 + product4 + product5 + product6 + product7;
    assign fir_out = sum[28:21];
endmodule
