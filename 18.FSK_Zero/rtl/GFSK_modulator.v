module gfsk_modulator#(
    parameter BASE_FWC = 655
) (
    input sys_clk,      
    input sys_rst_n,         
    input data_in,       
    output [7:0] da_data,
    output da_clk
);
    // ! PLL
    wire locked;
    wire clk_100m;
    wire clk_200m;
    wire clk_400m;
    assign rst = sys_rst_n & locked;

    pll	pll_inst (
        .areset ( ~sys_rst_n ),
        .inclk0 ( sys_clk ),
        .c0 ( clk_100m ),
        .c1 ( clk_200m ),
        .c2 ( clk_400m ),
        .locked ( locked )
        );


    // ! Gaussian filter
    wire [10:0] _da_data_flitered;
    gaussian_filter gf (
        .clk        ( clk_200m ),
        .rst_n      ( rst ),
        .data_in    ( data_in ),
        .filtered_out( _da_data_flitered )
    );


    // ! NOC output
    wire nco_clk;
    wire nco_vaild;
    assign nco_clk = clk_100m;
    // # DA Output
    wire [7:0] _da_data;

    _NCO noc_u (
        .clk        ( nco_clk ),
        .reset_n    ( rst ),
        .phi_inc_i  ( _da_data_flitered + BASE_FWC),
        .sin_out    ( _da_data ),
        .out_valid  ( nco_vaild )
    );

    // ! DA output
    assign da_data = _da_data;
    assign da_clk = nco_vaild & nco_clk;
    
endmodule