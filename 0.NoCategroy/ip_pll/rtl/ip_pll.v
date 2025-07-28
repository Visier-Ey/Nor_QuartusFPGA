module ip_pll (
    input sys_clk,
    input sys_rst_n,

    output clk_out100m,
    output clk_out100m_180deg,
    output clk_out50m,
    output clk_out25m,

    // ! segment LED
    output [7:0] seg_led,
    output [5:0] seg_sel
);
    
    wire rst_n;
    wire locked;

    //! PLL reset signal
    assign rst_n = sys_rst_n & locked;

    pll_clk	pll_clk_inst (
	.areset ( ~sys_rst_n ),
	.inclk0 ( sys_clk ),
	.c0 ( clk_out100m ),
	.c1 ( clk_out100m_180deg ),
	.c2 ( clk_out50m ),
	.c3 ( clk_out25m ),
	.locked ( locked )
	);


    // ! segmant LED Part
    wire count_down;

    i_seg_led u_seg_led (
        .sys_clk(clk_out100m),
        .sys_rst_n(rst_n),
        .count_down(count_down),
        .seg_led(seg_led),
        .seg_sel(seg_sel)
    );

    count u_count (
        .sys_clk(clk_out50m),
        .sys_rst_n(rst_n),
        .count_down(count_down)
    );
endmodule