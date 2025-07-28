module FIR_T (
    input sys_clk,
    input sys_rst_n,
    input data_in,
    output  wire    [7:0]   fir_in,   
    output  wire    [15:0]   fir_out     
);

    wire [7:0]  _da_data;
    wire [15:0]  _fir_out;
    wire        _fir_clk;
    assign fir_in = _da_data;
    assign fir_out = _fir_out;

    gfsk_modulator uudt (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .da_data(_da_data),
        .da_clk(_fir_clk)
    );

    FIR uut (
        .clk(sys_clk),
        .fir_in(_da_data - 128),
        .fir_out(_fir_out)
    );

endmodule