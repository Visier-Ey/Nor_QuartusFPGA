module _NCO #(
    parameter PHASE_WIDTH = 32,
    parameter OUTPUT_WIDTH = 8,
    parameter LUT_ADDR_WIDTH = 8,
    parameter BASE_PHASE = 0
)(
    input wire clk,
    input wire reset_n,
    input wire [PHASE_WIDTH-1:0] phi_inc_i, // freq control
    output wire [OUTPUT_WIDTH-1:0] sin_out,
    output wire [OUTPUT_WIDTH-1:0] cos_out,
    output reg out_valid
);

    // --- Phase accumulator ---
    reg [PHASE_WIDTH-1:0] phase_accum;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            phase_accum <= BASE_PHASE;
            out_valid <= 0;
        end else begin
            phase_accum <= phase_accum + phi_inc_i;
            out_valid <= 1'b1;
        end
    end

    // --- ROM instance (256x8) ---
    wire [LUT_ADDR_WIDTH-1:0] rom_addr_sin;
    wire [LUT_ADDR_WIDTH-1:0] rom_addr_cos;
    wire [OUTPUT_WIDTH-1:0] rom_q_sin;
    wire [OUTPUT_WIDTH-1:0] rom_q_cos;

    rom_256x8b u_rom_sin (
        .address(rom_addr_sin),
        .clock(clk),
        .q(rom_q_sin)
    );

    rom_256x8b u_rom_cos (
        .address(rom_addr_cos),
        .clock(clk),
        .q(rom_q_cos)
    );

    // --- Address decode ---
    wire [LUT_ADDR_WIDTH-1:0] base_addr;
    assign base_addr = phase_accum[PHASE_WIDTH-1 : PHASE_WIDTH - LUT_ADDR_WIDTH] +
                       {{(LUT_ADDR_WIDTH-1){1'b0}}, phase_accum[PHASE_WIDTH - LUT_ADDR_WIDTH - 1]};

    assign rom_addr_sin = base_addr;
    assign rom_addr_cos = base_addr + (1 << (LUT_ADDR_WIDTH - 2)); // +90°

    // --- Output mapping ---
    assign sin_out = rom_q_sin;
    assign cos_out = rom_q_cos;

endmodule
