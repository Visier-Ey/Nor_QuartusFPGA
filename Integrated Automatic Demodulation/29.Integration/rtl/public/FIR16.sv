// 63阶有符号FIR滤波器，截止频率=0.001π，输入16位
module FIR16 (
    input clk,
    input signed [15:0] fir_in,
    output signed [15:0] fir_out
);
    reg signed [15:0] delay_line [0:62];

    // 量化系数（最大绝对值=32767）
    localparam signed [15:0] coeff0 = 16'sd2617;
    localparam signed [15:0] coeff1 = 16'sd2695;
    localparam signed [15:0] coeff2 = 16'sd2926;
    localparam signed [15:0] coeff3 = 16'sd3308;
    localparam signed [15:0] coeff4 = 16'sd3838;
    localparam signed [15:0] coeff5 = 16'sd4510;
    localparam signed [15:0] coeff6 = 16'sd5317;
    localparam signed [15:0] coeff7 = 16'sd6252;
    localparam signed [15:0] coeff8 = 16'sd7303;
    localparam signed [15:0] coeff9 = 16'sd8461;
    localparam signed [15:0] coeff10 = 16'sd9714;
    localparam signed [15:0] coeff11 = 16'sd11049;
    localparam signed [15:0] coeff12 = 16'sd12452;
    localparam signed [15:0] coeff13 = 16'sd13909;
    localparam signed [15:0] coeff14 = 16'sd15404;
    localparam signed [15:0] coeff15 = 16'sd16924;
    localparam signed [15:0] coeff16 = 16'sd18451;
    localparam signed [15:0] coeff17 = 16'sd19970;
    localparam signed [15:0] coeff18 = 16'sd21466;
    localparam signed [15:0] coeff19 = 16'sd22924;
    localparam signed [15:0] coeff20 = 16'sd24327;
    localparam signed [15:0] coeff21 = 16'sd25663;
    localparam signed [15:0] coeff22 = 16'sd26917;
    localparam signed [15:0] coeff23 = 16'sd28076;
    localparam signed [15:0] coeff24 = 16'sd29128;
    localparam signed [15:0] coeff25 = 16'sd30064;
    localparam signed [15:0] coeff26 = 16'sd30872;
    localparam signed [15:0] coeff27 = 16'sd31545;
    localparam signed [15:0] coeff28 = 16'sd32075;
    localparam signed [15:0] coeff29 = 16'sd32458;
    localparam signed [15:0] coeff30 = 16'sd32690;
    localparam signed [15:0] coeff31 = 16'sd32767;

    // 移位寄存器实现
    always @(posedge clk) begin
        integer i;
        for (i = 62; i > 0; i = i - 1)
            delay_line[i] <= delay_line[i-1];
        delay_line[0] <= fir_in;
    end

    // 有符号乘法和累加
    wire signed [31:0] product0, product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11, product12, product13, product14, product15, product16, product17, product18, product19, product20, product21, product22, product23, product24, product25, product26, product27, product28, product29, product30, product31;
    assign product0 = (delay_line[0] + delay_line[62]) * coeff0;
    assign product1 = (delay_line[1] + delay_line[61]) * coeff1;
    assign product2 = (delay_line[2] + delay_line[60]) * coeff2;
    assign product3 = (delay_line[3] + delay_line[59]) * coeff3;
    assign product4 = (delay_line[4] + delay_line[58]) * coeff4;
    assign product5 = (delay_line[5] + delay_line[57]) * coeff5;
    assign product6 = (delay_line[6] + delay_line[56]) * coeff6;
    assign product7 = (delay_line[7] + delay_line[55]) * coeff7;
    assign product8 = (delay_line[8] + delay_line[54]) * coeff8;
    assign product9 = (delay_line[9] + delay_line[53]) * coeff9;
    assign product10 = (delay_line[10] + delay_line[52]) * coeff10;
    assign product11 = (delay_line[11] + delay_line[51]) * coeff11;
    assign product12 = (delay_line[12] + delay_line[50]) * coeff12;
    assign product13 = (delay_line[13] + delay_line[49]) * coeff13;
    assign product14 = (delay_line[14] + delay_line[48]) * coeff14;
    assign product15 = (delay_line[15] + delay_line[47]) * coeff15;
    assign product16 = (delay_line[16] + delay_line[46]) * coeff16;
    assign product17 = (delay_line[17] + delay_line[45]) * coeff17;
    assign product18 = (delay_line[18] + delay_line[44]) * coeff18;
    assign product19 = (delay_line[19] + delay_line[43]) * coeff19;
    assign product20 = (delay_line[20] + delay_line[42]) * coeff20;
    assign product21 = (delay_line[21] + delay_line[41]) * coeff21;
    assign product22 = (delay_line[22] + delay_line[40]) * coeff22;
    assign product23 = (delay_line[23] + delay_line[39]) * coeff23;
    assign product24 = (delay_line[24] + delay_line[38]) * coeff24;
    assign product25 = (delay_line[25] + delay_line[37]) * coeff25;
    assign product26 = (delay_line[26] + delay_line[36]) * coeff26;
    assign product27 = (delay_line[27] + delay_line[35]) * coeff27;
    assign product28 = (delay_line[28] + delay_line[34]) * coeff28;
    assign product29 = (delay_line[29] + delay_line[33]) * coeff29;
    assign product30 = (delay_line[30] + delay_line[32]) * coeff30;
    assign product31 = delay_line[31] * coeff31;

    wire signed [37:0] sum = product0 + product1 + product2 + product3 + product4 + product5 + product6 + product7 + product8 + product9 + product10 + product11 + product12 + product13 + product14 + product15 + product16 + product17 + product18 + product19 + product20 + product21 + product22 + product23 + product24 + product25 + product26 + product27 + product28 + product29 + product30 + product31;
    assign fir_out = sum[37:22];  // 右移22位，输出16位
endmodule