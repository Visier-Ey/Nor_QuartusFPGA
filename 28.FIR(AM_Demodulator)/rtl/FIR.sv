// 127阶有符号FIR滤波器
// 截止频率=0.01π，输入=16位，输出=14位
module FIR (
    input clk,
    input signed [15:0] fir_in,
    output signed [13:0] fir_out
);
    reg signed [15:0] delay_line [0:126];

    // 量化系数（自动处理负数）
    localparam signed [12:0] coeff0 = 13'sd152;
    localparam signed [12:0] coeff1 = 13'sd157;
    localparam signed [12:0] coeff2 = 13'sd165;
    localparam signed [12:0] coeff3 = 13'sd176;
    localparam signed [12:0] coeff4 = 13'sd189;
    localparam signed [12:0] coeff5 = 13'sd205;
    localparam signed [12:0] coeff6 = 13'sd224;
    localparam signed [12:0] coeff7 = 13'sd246;
    localparam signed [12:0] coeff8 = 13'sd272;
    localparam signed [12:0] coeff9 = 13'sd301;
    localparam signed [12:0] coeff10 = 13'sd333;
    localparam signed [12:0] coeff11 = 13'sd369;
    localparam signed [12:0] coeff12 = 13'sd409;
    localparam signed [12:0] coeff13 = 13'sd452;
    localparam signed [12:0] coeff14 = 13'sd499;
    localparam signed [12:0] coeff15 = 13'sd550;
    localparam signed [12:0] coeff16 = 13'sd604;
    localparam signed [12:0] coeff17 = 13'sd662;
    localparam signed [12:0] coeff18 = 13'sd724;
    localparam signed [12:0] coeff19 = 13'sd790;
    localparam signed [12:0] coeff20 = 13'sd859;
    localparam signed [12:0] coeff21 = 13'sd932;
    localparam signed [12:0] coeff22 = 13'sd1008;
    localparam signed [12:0] coeff23 = 13'sd1087;
    localparam signed [12:0] coeff24 = 13'sd1170;
    localparam signed [12:0] coeff25 = 13'sd1255;
    localparam signed [12:0] coeff26 = 13'sd1343;
    localparam signed [12:0] coeff27 = 13'sd1434;
    localparam signed [12:0] coeff28 = 13'sd1527;
    localparam signed [12:0] coeff29 = 13'sd1622;
    localparam signed [12:0] coeff30 = 13'sd1719;
    localparam signed [12:0] coeff31 = 13'sd1818;
    localparam signed [12:0] coeff32 = 13'sd1918;
    localparam signed [12:0] coeff33 = 13'sd2019;
    localparam signed [12:0] coeff34 = 13'sd2121;
    localparam signed [12:0] coeff35 = 13'sd2223;
    localparam signed [12:0] coeff36 = 13'sd2326;
    localparam signed [12:0] coeff37 = 13'sd2429;
    localparam signed [12:0] coeff38 = 13'sd2531;
    localparam signed [12:0] coeff39 = 13'sd2632;
    localparam signed [12:0] coeff40 = 13'sd2733;
    localparam signed [12:0] coeff41 = 13'sd2832;
    localparam signed [12:0] coeff42 = 13'sd2929;
    localparam signed [12:0] coeff43 = 13'sd3025;
    localparam signed [12:0] coeff44 = 13'sd3118;
    localparam signed [12:0] coeff45 = 13'sd3208;
    localparam signed [12:0] coeff46 = 13'sd3296;
    localparam signed [12:0] coeff47 = 13'sd3380;
    localparam signed [12:0] coeff48 = 13'sd3461;
    localparam signed [12:0] coeff49 = 13'sd3538;
    localparam signed [12:0] coeff50 = 13'sd3611;
    localparam signed [12:0] coeff51 = 13'sd3679;
    localparam signed [12:0] coeff52 = 13'sd3743;
    localparam signed [12:0] coeff53 = 13'sd3802;
    localparam signed [12:0] coeff54 = 13'sd3857;
    localparam signed [12:0] coeff55 = 13'sd3906;
    localparam signed [12:0] coeff56 = 13'sd3949;
    localparam signed [12:0] coeff57 = 13'sd3988;
    localparam signed [12:0] coeff58 = 13'sd4020;
    localparam signed [12:0] coeff59 = 13'sd4047;
    localparam signed [12:0] coeff60 = 13'sd4068;
    localparam signed [12:0] coeff61 = 13'sd4083;
    localparam signed [12:0] coeff62 = 13'sd4092;
    localparam signed [12:0] coeff63 = 13'sd4095;

    always @(posedge clk) begin
        integer i;
        for (i = 126; i > 0; i = i - 1)
            delay_line[i] <= delay_line[i-1];
        delay_line[0] <= fir_in;
    end

    wire signed [28:0] product0, product1, product2, product3, product4, product5, product6, product7, product8, product9, product10, product11, product12, product13, product14, product15, product16, product17, product18, product19, product20, product21, product22, product23, product24, product25, product26, product27, product28, product29, product30, product31, product32, product33, product34, product35, product36, product37, product38, product39, product40, product41, product42, product43, product44, product45, product46, product47, product48, product49, product50, product51, product52, product53, product54, product55, product56, product57, product58, product59, product60, product61, product62, product63;
    assign product0 = (delay_line[0] + delay_line[126]) * coeff0;
    assign product1 = (delay_line[1] + delay_line[125]) * coeff1;
    assign product2 = (delay_line[2] + delay_line[124]) * coeff2;
    assign product3 = (delay_line[3] + delay_line[123]) * coeff3;
    assign product4 = (delay_line[4] + delay_line[122]) * coeff4;
    assign product5 = (delay_line[5] + delay_line[121]) * coeff5;
    assign product6 = (delay_line[6] + delay_line[120]) * coeff6;
    assign product7 = (delay_line[7] + delay_line[119]) * coeff7;
    assign product8 = (delay_line[8] + delay_line[118]) * coeff8;
    assign product9 = (delay_line[9] + delay_line[117]) * coeff9;
    assign product10 = (delay_line[10] + delay_line[116]) * coeff10;
    assign product11 = (delay_line[11] + delay_line[115]) * coeff11;
    assign product12 = (delay_line[12] + delay_line[114]) * coeff12;
    assign product13 = (delay_line[13] + delay_line[113]) * coeff13;
    assign product14 = (delay_line[14] + delay_line[112]) * coeff14;
    assign product15 = (delay_line[15] + delay_line[111]) * coeff15;
    assign product16 = (delay_line[16] + delay_line[110]) * coeff16;
    assign product17 = (delay_line[17] + delay_line[109]) * coeff17;
    assign product18 = (delay_line[18] + delay_line[108]) * coeff18;
    assign product19 = (delay_line[19] + delay_line[107]) * coeff19;
    assign product20 = (delay_line[20] + delay_line[106]) * coeff20;
    assign product21 = (delay_line[21] + delay_line[105]) * coeff21;
    assign product22 = (delay_line[22] + delay_line[104]) * coeff22;
    assign product23 = (delay_line[23] + delay_line[103]) * coeff23;
    assign product24 = (delay_line[24] + delay_line[102]) * coeff24;
    assign product25 = (delay_line[25] + delay_line[101]) * coeff25;
    assign product26 = (delay_line[26] + delay_line[100]) * coeff26;
    assign product27 = (delay_line[27] + delay_line[99]) * coeff27;
    assign product28 = (delay_line[28] + delay_line[98]) * coeff28;
    assign product29 = (delay_line[29] + delay_line[97]) * coeff29;
    assign product30 = (delay_line[30] + delay_line[96]) * coeff30;
    assign product31 = (delay_line[31] + delay_line[95]) * coeff31;
    assign product32 = (delay_line[32] + delay_line[94]) * coeff32;
    assign product33 = (delay_line[33] + delay_line[93]) * coeff33;
    assign product34 = (delay_line[34] + delay_line[92]) * coeff34;
    assign product35 = (delay_line[35] + delay_line[91]) * coeff35;
    assign product36 = (delay_line[36] + delay_line[90]) * coeff36;
    assign product37 = (delay_line[37] + delay_line[89]) * coeff37;
    assign product38 = (delay_line[38] + delay_line[88]) * coeff38;
    assign product39 = (delay_line[39] + delay_line[87]) * coeff39;
    assign product40 = (delay_line[40] + delay_line[86]) * coeff40;
    assign product41 = (delay_line[41] + delay_line[85]) * coeff41;
    assign product42 = (delay_line[42] + delay_line[84]) * coeff42;
    assign product43 = (delay_line[43] + delay_line[83]) * coeff43;
    assign product44 = (delay_line[44] + delay_line[82]) * coeff44;
    assign product45 = (delay_line[45] + delay_line[81]) * coeff45;
    assign product46 = (delay_line[46] + delay_line[80]) * coeff46;
    assign product47 = (delay_line[47] + delay_line[79]) * coeff47;
    assign product48 = (delay_line[48] + delay_line[78]) * coeff48;
    assign product49 = (delay_line[49] + delay_line[77]) * coeff49;
    assign product50 = (delay_line[50] + delay_line[76]) * coeff50;
    assign product51 = (delay_line[51] + delay_line[75]) * coeff51;
    assign product52 = (delay_line[52] + delay_line[74]) * coeff52;
    assign product53 = (delay_line[53] + delay_line[73]) * coeff53;
    assign product54 = (delay_line[54] + delay_line[72]) * coeff54;
    assign product55 = (delay_line[55] + delay_line[71]) * coeff55;
    assign product56 = (delay_line[56] + delay_line[70]) * coeff56;
    assign product57 = (delay_line[57] + delay_line[69]) * coeff57;
    assign product58 = (delay_line[58] + delay_line[68]) * coeff58;
    assign product59 = (delay_line[59] + delay_line[67]) * coeff59;
    assign product60 = (delay_line[60] + delay_line[66]) * coeff60;
    assign product61 = (delay_line[61] + delay_line[65]) * coeff61;
    assign product62 = (delay_line[62] + delay_line[64]) * coeff62;
    assign product63 = delay_line[63] * coeff63;

    wire signed [35:0] sum = product0 + product1 + product2 + product3 + product4 + product5 + product6 + product7 + product8 + product9 + product10 + product11 + product12 + product13 + product14 + product15 + product16 + product17 + product18 + product19 + product20 + product21 + product22 + product23 + product24 + product25 + product26 + product27 + product28 + product29 + product30 + product31 + product32 + product33 + product34 + product35 + product36 + product37 + product38 + product39 + product40 + product41 + product42 + product43 + product44 + product45 + product46 + product47 + product48 + product49 + product50 + product51 + product52 + product53 + product54 + product55 + product56 + product57 + product58 + product59 + product60 + product61 + product62 + product63;
    assign fir_out = sum[35:22];
endmodule