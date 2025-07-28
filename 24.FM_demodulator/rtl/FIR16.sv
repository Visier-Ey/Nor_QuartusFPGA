// 91阶有符号FIR滤波器，截止频率=0.01π，输入16位
module FIR16 (
    input clk,
    input signed [15:0] fir_in,
    output signed [15:0] fir_out
);
    reg signed [15:0] delay_line [0:90];

    // 量化系数（最大绝对值=32767）
    localparam signed [15:0] coeff0 = 16'sd1831;
    localparam signed [15:0] coeff1 = 16'sd1889;
    localparam signed [15:0] coeff2 = 16'sd2000;
    localparam signed [15:0] coeff3 = 16'sd2166;
    localparam signed [15:0] coeff4 = 16'sd2390;
    localparam signed [15:0] coeff5 = 16'sd2672;
    localparam signed [15:0] coeff6 = 16'sd3014;
    localparam signed [15:0] coeff7 = 16'sd3416;
    localparam signed [15:0] coeff8 = 16'sd3878;
    localparam signed [15:0] coeff9 = 16'sd4400;
    localparam signed [15:0] coeff10 = 16'sd4982;
    localparam signed [15:0] coeff11 = 16'sd5621;
    localparam signed [15:0] coeff12 = 16'sd6317;
    localparam signed [15:0] coeff13 = 16'sd7067;
    localparam signed [15:0] coeff14 = 16'sd7869;
    localparam signed [15:0] coeff15 = 16'sd8719;
    localparam signed [15:0] coeff16 = 16'sd9615;
    localparam signed [15:0] coeff17 = 16'sd10553;
    localparam signed [15:0] coeff18 = 16'sd11528;
    localparam signed [15:0] coeff19 = 16'sd12537;
    localparam signed [15:0] coeff20 = 16'sd13574;
    localparam signed [15:0] coeff21 = 16'sd14634;
    localparam signed [15:0] coeff22 = 16'sd15713;
    localparam signed [15:0] coeff23 = 16'sd16804;
    localparam signed [15:0] coeff24 = 16'sd17902;
    localparam signed [15:0] coeff25 = 16'sd19001;
    localparam signed [15:0] coeff26 = 16'sd20096;
    localparam signed [15:0] coeff27 = 16'sd21180;
    localparam signed [15:0] coeff28 = 16'sd22247;
    localparam signed [15:0] coeff29 = 16'sd23291;
    localparam signed [15:0] coeff30 = 16'sd24307;
    localparam signed [15:0] coeff31 = 16'sd25289;
    localparam signed [15:0] coeff32 = 16'sd26230;
    localparam signed [15:0] coeff33 = 16'sd27127;
    localparam signed [15:0] coeff34 = 16'sd27972;
    localparam signed [15:0] coeff35 = 16'sd28762;
    localparam signed [15:0] coeff36 = 16'sd29492;
    localparam signed [15:0] coeff37 = 16'sd30157;
    localparam signed [15:0] coeff38 = 16'sd30753;
    localparam signed [15:0] coeff39 = 16'sd31278;
    localparam signed [15:0] coeff40 = 16'sd31727;
    localparam signed [15:0] coeff41 = 16'sd32098;
    localparam signed [15:0] coeff42 = 16'sd32390;
    localparam signed [15:0] coeff43 = 16'sd32599;
    localparam signed [15:0] coeff44 = 16'sd32725;
    localparam signed [15:0] coeff45 = 16'sd32767;

    // 移位寄存器实现
    always @(posedge clk) begin
        integer i;
        for (i = 90; i > 0; i = i - 1)
            delay_line[i] <= delay_line[i-1];
        delay_line[0] <= fir_in;
    end

    // 有符号乘法和累加
    wire signed [31:0] product0, product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11, product12, product13, product14, product15, product16, product17, product18, product19, product20, product21, product22, product23, product24, product25, product26, product27, product28, product29, product30, product31, product32, product33, product34, product35, product36, product37, product38, product39, product40, product41, product42, product43, product44, product45;
    assign product0 = (delay_line[0] + delay_line[90]) * coeff0;
    assign product1 = (delay_line[1] + delay_line[89]) * coeff1;
    assign product2 = (delay_line[2] + delay_line[88]) * coeff2;
    assign product3 = (delay_line[3] + delay_line[87]) * coeff3;
    assign product4 = (delay_line[4] + delay_line[86]) * coeff4;
    assign product5 = (delay_line[5] + delay_line[85]) * coeff5;
    assign product6 = (delay_line[6] + delay_line[84]) * coeff6;
    assign product7 = (delay_line[7] + delay_line[83]) * coeff7;
    assign product8 = (delay_line[8] + delay_line[82]) * coeff8;
    assign product9 = (delay_line[9] + delay_line[81]) * coeff9;
    assign product10 = (delay_line[10] + delay_line[80]) * coeff10;
    assign product11 = (delay_line[11] + delay_line[79]) * coeff11;
    assign product12 = (delay_line[12] + delay_line[78]) * coeff12;
    assign product13 = (delay_line[13] + delay_line[77]) * coeff13;
    assign product14 = (delay_line[14] + delay_line[76]) * coeff14;
    assign product15 = (delay_line[15] + delay_line[75]) * coeff15;
    assign product16 = (delay_line[16] + delay_line[74]) * coeff16;
    assign product17 = (delay_line[17] + delay_line[73]) * coeff17;
    assign product18 = (delay_line[18] + delay_line[72]) * coeff18;
    assign product19 = (delay_line[19] + delay_line[71]) * coeff19;
    assign product20 = (delay_line[20] + delay_line[70]) * coeff20;
    assign product21 = (delay_line[21] + delay_line[69]) * coeff21;
    assign product22 = (delay_line[22] + delay_line[68]) * coeff22;
    assign product23 = (delay_line[23] + delay_line[67]) * coeff23;
    assign product24 = (delay_line[24] + delay_line[66]) * coeff24;
    assign product25 = (delay_line[25] + delay_line[65]) * coeff25;
    assign product26 = (delay_line[26] + delay_line[64]) * coeff26;
    assign product27 = (delay_line[27] + delay_line[63]) * coeff27;
    assign product28 = (delay_line[28] + delay_line[62]) * coeff28;
    assign product29 = (delay_line[29] + delay_line[61]) * coeff29;
    assign product30 = (delay_line[30] + delay_line[60]) * coeff30;
    assign product31 = (delay_line[31] + delay_line[59]) * coeff31;
    assign product32 = (delay_line[32] + delay_line[58]) * coeff32;
    assign product33 = (delay_line[33] + delay_line[57]) * coeff33;
    assign product34 = (delay_line[34] + delay_line[56]) * coeff34;
    assign product35 = (delay_line[35] + delay_line[55]) * coeff35;
    assign product36 = (delay_line[36] + delay_line[54]) * coeff36;
    assign product37 = (delay_line[37] + delay_line[53]) * coeff37;
    assign product38 = (delay_line[38] + delay_line[52]) * coeff38;
    assign product39 = (delay_line[39] + delay_line[51]) * coeff39;
    assign product40 = (delay_line[40] + delay_line[50]) * coeff40;
    assign product41 = (delay_line[41] + delay_line[49]) * coeff41;
    assign product42 = (delay_line[42] + delay_line[48]) * coeff42;
    assign product43 = (delay_line[43] + delay_line[47]) * coeff43;
    assign product44 = (delay_line[44] + delay_line[46]) * coeff44;
    assign product45 = delay_line[45] * coeff45;

    wire signed [38:0] sum = product0 + product1 + product2 + product3 + product4 + product5 + product6 + product7 + product8 + product9 + product10 + product11 + product12 + product13 + product14 + product15 + product16 + product17 + product18 + product19 + product20 + product21 + product22 + product23 + product24 + product25 + product26 + product27 + product28 + product29 + product30 + product31 + product32 + product33 + product34 + product35 + product36 + product37 + product38 + product39 + product40 + product41 + product42 + product43 + product44 + product45;
    assign fir_out = sum[38:23];  // 右移23位，输出16位
endmodule