module FSK_Zero (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire data_in,
    output wire [7:0] da_data,
    output wire demodulated_bit
);
    wire da_clk;

    // ! FSK modulator
    gfsk_modulator uudt (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .data_in(data_in),
        .da_data(da_data),
        .da_clk(da_clk)
    );

    // ! FSK demodulator
    fsk_demodulator uut (
         .clk(sys_clk),          
         .rst_n(sys_rst_n),           
         .ad_data(da_data),  
         .demodulated_bit(demodulated_bit)   
    );

    
endmodule