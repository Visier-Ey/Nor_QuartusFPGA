module psk_modulator#(
    parameter BASE_PHASE = 655
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

    pll pll_inst (
        .areset ( ~sys_rst_n ),
        .inclk0 ( sys_clk ),
        .c0 ( clk_100m ),
        .c1 ( clk_200m ),
        .c2 ( clk_400m ),
        .locked ( locked )
    );

    // ! PSK Phase Control
    reg [31:0] phase_inc;
    reg data_in_prev;
    reg data_in_prev2;
    always @(posedge clk_100m or negedge rst) begin
        if(!rst) begin
            data_in_prev <= 1'b0;
            data_in_prev2 <= 1'b0;
        end else begin
            data_in_prev2 <= data_in_prev;
            data_in_prev <= data_in;
        end
    end

    always @(posedge clk_200m or negedge rst) begin
        if(!rst) begin
            phase_inc <= BASE_PHASE;
        end else if(data_in != data_in_prev2) begin
            phase_inc <= BASE_PHASE + 16'h8000;
        end 
        else if (phase_inc>= 16'h8000) begin
            phase_inc <= BASE_PHASE;
        end 
    end

    // ! NOC output
    wire nco_clk;
    wire nco_valid;
    assign nco_clk = clk_100m;
    
    wire [7:0] _da_data;

    _NCO #(
        .PHASE_WIDTH(16)
    ) noc_u  (
        .clk        ( nco_clk ),
        .reset_n    ( rst ),
        .phi_inc_i  ( phase_inc ), 
        .sin_out    ( _da_data ),
        .out_valid  ( nco_valid )
    );

    // ! DA output
    assign da_data = _da_data;
    assign da_clk = nco_valid & nco_clk;
endmodule