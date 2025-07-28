module top_FSK (
    input sys_clk,
    input sys_rst_n,
    input opt,
    output [7:0] da_data,
    output da_clk
);

// ! clock PLL
wire locked;
assign   rst_n = sys_rst_n & locked ;
pll	u_pll (
    .areset      ( ~sys_rst_n ),
    .inclk0      ( sys_clk ),
    .c0          ( clk_100m ),
    .c1          ( clk_10m ),
    .locked      ( locked )
    );

//! FSK

FSK u_FSK(
    .sys_clk     (clk_100m),
    .sys_rst_n   (rst_n),
    .opt         (opt),
    .da_data     (da_data),
    .da_clk      (da_clk)
);

endmodule