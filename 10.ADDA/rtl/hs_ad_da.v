
module hs_ad_da(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
    //DA芯片接口
    output                da_clk      ,  //DAC驱动时钟
    output    [7:0]       da_data     ,  //输出给DA的数据
    //AD芯片接口
    input     [7:0]       ad_data     ,  //AD输入数据
    //模拟输入电压超出量程标志(本次试验未用到)
    input                 ad_otr      ,  //0:在量程范围 1:超出量程
    output                ad_clk         //ADC驱动时钟
);

//wire define 
wire      [7:0]    rd_addr       ;       //ROM读地址
wire      [7:0]    rd_data       ;       //ROM读出的数据
wire               clk_100m      ;       //100MHz时钟
wire               clk_100_180degm;    //100MHz时钟，180度相位差
wire               clk_50m       ;       //50MHz时钟
wire               clk_25m       ;       //25MHz时钟
wire               locked        ;       //pll时钟锁定信号
wire               rst_n         ;       //复位信号，低有效

//*****************************************************
//**                    main code
//*****************************************************

//通过系统复位信号和PLL时钟锁定信号来产生一个新的复位信号
assign   rst_n = sys_rst_n & locked ;
assign   ad_clk = clk_25m ;

//pll
pll	u_pll (
    .areset      ( ~sys_rst_n ),
    .inclk0      ( sys_clk ),
    .c0          ( clk_100m ),
    .c1          ( clk_100_180degm ),
    .c2          ( clk_50m ),
    .c3          ( clk_25m ),
    .locked      ( locked )
    );
//DA数据发送
da_wave_send u_da_wave_send(
    .clk         (clk_100m  ), 
    .rst_n       (rst_n    ),
    .rd_data     (rd_data  ),
    .rd_addr     (rd_addr  ),
    .da_clk      (da_clk   ),  
    .da_data     (da_data  )
    );

//ROM存储波形
rom_256x8b	u_rom_256x8b (
    .address    ( rd_addr ),
    .clock      ( clk_100m ),
    .q          ( rd_data )
    );


endmodule