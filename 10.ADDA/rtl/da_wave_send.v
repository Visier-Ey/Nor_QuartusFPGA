//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           da_wave_send
// Created by:          正点原子
// Created date:        2023年5月31日14:17:02
// Version:             V1.0
// Descriptions:        DA波形数据发送模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module da_wave_send(
    input                 clk    ,  //时钟
    input                 rst_n  ,  //复位信号，低电平有效
    
    input        [7:0]    rd_data,  //ROM读出的数据
    output  reg  [7:0]    rd_addr,  //读ROM地址
    //DA芯片接口
    output                da_clk ,  //DAC驱动时钟
    output       [7:0]    da_data   //输出给DA的数据  
    );

//parameter
//频率调节控制
parameter  FREQ_ADJ = 8'd0;  //频率调节,FREQ_ADJ的越大,最终输出的频率越低,范围0~255

//reg define
reg    [7:0]    freq_cnt  ;  //频率调节计数器

//*****************************************************
//**                    main code
//*****************************************************

//数据rd_data是在clk的上升沿更新的，所以DA芯片在clk的下降沿锁存数据是稳定的时刻
//而DA实际上在da_clk的上升沿锁存数据,所以时钟取反,这样clk的下降沿相当于da_clk的上升沿
assign  da_clk = ~clk;       
assign  da_data = rd_data;   //将读到的ROM数据赋值给DA数据端口

//频率调节计数器
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        freq_cnt <= 8'd0;
    else if(freq_cnt == FREQ_ADJ)    
        freq_cnt <= 8'd0;
    else         
        freq_cnt <= freq_cnt + 8'd1;
end

//读ROM地址
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_addr <= 8'd0;
    else begin
        if((freq_cnt == FREQ_ADJ) && (rd_addr < 8'd255))
            rd_addr <= rd_addr + 8'd1;
        else if((freq_cnt == FREQ_ADJ) && (rd_addr == 8'd255))
            rd_addr <= 8'd0;
        else
            rd_addr <= rd_addr;
    end            
end

endmodule