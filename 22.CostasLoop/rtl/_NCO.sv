module _NCO #(
    parameter PHASE_WIDTH = 32,
    parameter OUTPUT_WIDTH = 8,
    parameter LUT_ADDR_WIDTH = 8,
    parameter BASE_PHASE = 0
)(
    input clk,
    input reset_n,
    input [PHASE_WIDTH-1:0] phi_inc_i, //* fwc = 2^N * f_out / f_clk
    output wire [OUTPUT_WIDTH-1:0] nco_out,
    output reg out_valid
);

// ! Phase accumulator
reg [PHASE_WIDTH-1:0] phase_accum;

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        phase_accum <= BASE_PHASE;
        out_valid <= 0;
    end else begin
        phase_accum <= phase_accum + phi_inc_i;
        out_valid <= 1'b1;
    end
end


// ! lut content transfer
wire [LUT_ADDR_WIDTH-1:0] _rd_address;
wire [OUTPUT_WIDTH-1:0] _rd_data;

rom_256x8b	u_rom_256x8b (
    .address    ( _rd_address ),
    .clock      ( clk ),
    .q          ( _rd_data )
);

// ! LUT 
wire [LUT_ADDR_WIDTH-1:0] lut_addr;
// assign lut_addr = phase_accum[PHASE_WIDTH-1:PHASE_WIDTH-LUT_ADDR_WIDTH] + phase_accum[PHASE_WIDTH-LUT_ADDR_WIDTH-1];
assign lut_addr = phase_accum[PHASE_WIDTH-1:PHASE_WIDTH-LUT_ADDR_WIDTH] + {{(LUT_ADDR_WIDTH-1){1'b0}}, phase_accum[PHASE_WIDTH-LUT_ADDR_WIDTH-1]}; // * Cut high BIT

// ! LUT read
assign _rd_address = lut_addr;
assign nco_out = _rd_data;


endmodule