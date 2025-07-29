// 31阶有符号FIR滤波器，截止频率=0.001π
module FIR (
    input clk,
    input signed [7:0] fir_in,  // 8位有符号输入(-128~127)
    output signed [15:0] fir_out // 16位有符号输出
);
    reg signed [7:0] delay_line [0:30];

    // 量化系数（最大绝对值=1024）
    localparam signed [11:0] coeff0 = 12'sd82;
    localparam signed [11:0] coeff1 = 12'sd92;
    localparam signed [11:0] coeff2 = 12'sd123;
    localparam signed [11:0] coeff3 = 12'sd172;
    localparam signed [11:0] coeff4 = 12'sd238;
    localparam signed [11:0] coeff5 = 12'sd317;
    localparam signed [11:0] coeff6 = 12'sd407;
    localparam signed [11:0] coeff7 = 12'sd504;
    localparam signed [11:0] coeff8 = 12'sd602;
    localparam signed [11:0] coeff9 = 12'sd698;
    localparam signed [11:0] coeff10 = 12'sd788;
    localparam signed [11:0] coeff11 = 12'sd868;
    localparam signed [11:0] coeff12 = 12'sd934;
    localparam signed [11:0] coeff13 = 12'sd983;
    localparam signed [11:0] coeff14 = 12'sd1014;
    localparam signed [11:0] coeff15 = 12'sd1024;

    always @(posedge clk) begin
        for (int i=30; i>0; i=i-1)
            delay_line[i] <= delay_line[i-1];
        delay_line[0] <= fir_in;
    end

    // 有符号乘累加运算
    wire signed [19:0] product0, product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11, product12, product13, product14, product15;
    assign product0 = (delay_line[0] + delay_line[30]) * coeff0;
    assign product1 = (delay_line[1] + delay_line[29]) * coeff1;
    assign product2 = (delay_line[2] + delay_line[28]) * coeff2;
    assign product3 = (delay_line[3] + delay_line[27]) * coeff3;
    assign product4 = (delay_line[4] + delay_line[26]) * coeff4;
    assign product5 = (delay_line[5] + delay_line[25]) * coeff5;
    assign product6 = (delay_line[6] + delay_line[24]) * coeff6;
    assign product7 = (delay_line[7] + delay_line[23]) * coeff7;
    assign product8 = (delay_line[8] + delay_line[22]) * coeff8;
    assign product9 = (delay_line[9] + delay_line[21]) * coeff9;
    assign product10 = (delay_line[10] + delay_line[20]) * coeff10;
    assign product11 = (delay_line[11] + delay_line[19]) * coeff11;
    assign product12 = (delay_line[12] + delay_line[18]) * coeff12;
    assign product13 = (delay_line[13] + delay_line[17]) * coeff13;
    assign product14 = (delay_line[14] + delay_line[16]) * coeff14;
    assign product15 = delay_line[15] * coeff15;

    // 累加和输出
    wire signed [21:0] sum = product0 + product1 + product2 + product3 + product4 + product5 + product6 + product7 + product8 + product9 + product10 + product11 + product12 + product13 + product14 + product15;
    // 根据系数最大值调整输出位宽
    assign fir_out = sum[21:6]; // 适当右移
endmodule