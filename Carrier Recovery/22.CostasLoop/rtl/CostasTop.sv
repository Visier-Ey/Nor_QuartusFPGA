module CostasTop(
    input            sys_clk  , //* 50MHz system clock
    input            sys_rst_n,

    input [7:0] ad_data,  
    output [7:0] da_data,    
    output da_clk,         
    output ad_clk
);


//*****************************************************
//**                    main code
//*****************************************************

// ! ============================= PLL Here =============================

wire locked;
wire clk_100m;
wire clk_30m;
wire clk_400m;
pll pll_inst (
    .areset ( ~sys_rst_n ), 
    .inclk0 ( sys_clk ),
    .c0 ( clk_100m ),
    .c1 ( clk_30m ),
    .c2 ( clk_400m ),
    .locked ( locked )
);


assign rst = sys_rst_n & locked;



// ! ============================= Costas Here =============================

reg [31:0] costas_freq_inc; 

costas costas_inst (
    .sys_clk(clk_30m),
    .sys_rst_n(rst),
    .ad_data(ad_data),  
    .da_data(da_data),  
    .da_clk(da_clk),    
    .ad_clk(ad_clk),    
    .initial_freq(costas_freq_inc)
);  


// ! ============================= Logic Here =============================

always @(posedge clk_30m or negedge rst) begin
    if (!rst) begin
        costas_freq_inc <= 32'd143165577  ;
    end else begin
    end

end


endmodule