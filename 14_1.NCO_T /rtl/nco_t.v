module nco_t (
    input sys_clk,
    input sys_rst_n,
    output [7:0] da_data,
    output da_clk
);

wire locked;
wire clk_100m;

assign rst = sys_rst_n & locked;

assign da_clk = clk_100m & da_clk_en;

  pll	pll_inst (
	.areset ( ~sys_rst_n ),
	.inclk0 ( sys_clk ),
	.c0 ( clk_100m ),
	.locked ( locked )
	);

// ! phi_inc_i = (desired_frequency × 2^N) / clock_frequency

  nco u0 (
        .clk       (clk_100m),       // clk.clk
        .reset_n   (rst),   // rst.reset_n
        .clken     (1'b1),     //  in.clken
        .phi_inc_i ('d13107), //    .phi_inc_i
        .fsin_o    (da_data),    // out.fsin_o
        .out_valid (da_clk_en)  //    .out_valid
    );

endmodule