module NCO # (
   parameter FCW = 6554  // * Frequency Control Word
   // * 1M here
   // ! FCW=​fout​×2^N/fclk
) (
    input sys_clk,
    input sys_rst_n,
    output [7:0] da_data,
    output da_clk
);

  // ! PLL
  wire locked;
  wire clk_100m;
  assign rst = sys_rst_n & locked;

  pll	pll_inst (
	.areset ( ~sys_rst_n ),
	.inclk0 ( sys_clk ),
	.c0 ( clk_100m ),
  .c1 ( clk_50m ),
	.locked ( locked )
	);


  // ! NOC output
  wire nco_clk;
  wire nco_vaild;
  // # DA Output
  wire [7:0] _da_data;
  assign da_clk = nco_vaild & nco_clk;
  assign da_data = _da_data;

  _NCO noc_u (
    .clk        ( clk_100m ),
    .reset_n    ( rst ),
    .phi_inc_i  ( FCW ),
    .sin_out    ( _da_data ),
    .out_valid  ( nco_vaild ),
    .nco_clk    ( nco_clk )
  );





endmodule