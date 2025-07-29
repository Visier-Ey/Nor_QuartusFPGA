module fm_demod (
    input wire clk,
    input wire rst_n,
    input wire signed [7:0] fm_in,
    input wire [31:0] phi_inc,
    output reg signed [15:0] demod_out,
    output wire [7:0] nco_sin,
    output wire [7:0] nco_cos,
    output wire [15:0] I,
    output wire [15:0] Q,
    output wire signed [15:0] I_mix,
    output wire signed [15:0] Q_mix,
    output wire signed [31:0] port,
    output reg signed [15:0] I_prev,
    output reg signed [15:0] Q_prev,
    output wire signed [15:0] I_in,
    output wire signed [15:0] Q_in

);

    // --- NCO: 单实例同时输出 sin / cos ---
    wire signed [7:0] _nco_sin_u, _nco_cos_u;
    wire signed [15:0] demod_;

    assign nco_sin = $signed(_nco_sin_u - 8'd128);
    assign nco_cos = $signed(_nco_cos_u - 8'd128);

    wire signed [15:0] mix_I, mix_Q;

    _NCO #(
        .BASE_PHASE(32'h00000000)
    ) nco_inst (
        .clk(clk),
        .reset_n(rst_n),
        .phi_inc_i(phi_inc),
        .sin_out(_nco_sin_u),
        .cos_out(_nco_cos_u),
        .out_valid()
    );

    // --- Mixing ---
     mixer u_mixer (
        .clk(clk),
        .rst(rst_n),
        .adc_data(fm_in),
        .nco_sin(nco_sin),  
        .nco_cos(nco_cos),  
        .I_out(mix_I),
        .Q_out(mix_Q)
    );
    
    assign I_mix = mix_I;
    assign Q_mix = mix_Q;

    // --- FIR Filtering ---
    wire signed [15:0] I_out, Q_out;
    FIR16 fir_I (.clk(clk), .fir_in(mix_I), .fir_out(I_out));
    FIR16 fir_Q (.clk(clk), .fir_in(mix_Q), .fir_out(Q_out));
    // 截断为8位用于后续解调
    // wire signed [15:0] I_in = I_out;
    // wire signed [15:0] Q_in = Q_out;
    assign I_in = I_out; // 保留16位
    assign Q_in = Q_out; // 保留16位

    // --- Demodulation (I·Q' - Q·I') ---
    // reg signed [15:0] I_prev, Q_prev;
        // 差分处理
    wire signed [15:0] dI = I_in - I_prev;
    wire signed [15:0] dQ = Q_in - Q_prev;
    // demod = I·dQ - Q·dI
    wire signed [31:0] mult1 = I_in * dQ;
    wire signed [31:0] mult2 = Q_in * dI;
    wire signed [31:0] delta_phi = mult1 - mult2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            I_prev <= 0;
            Q_prev <= 0;
            demod_out <= 0;
        end else begin
            I_prev <= I_in;
            Q_prev <= Q_in;
            demod_out <= delta_phi>>>8; // 截断为16位输出
        end
    end


    assign I = I_out;
    assign Q = Q_out;

    FIR fir_demod (.clk(clk), .fir_in(delta_phi), .fir_out(port));
    // assign port = delta_phi;
    //assign demod_out = demod_;

endmodule
