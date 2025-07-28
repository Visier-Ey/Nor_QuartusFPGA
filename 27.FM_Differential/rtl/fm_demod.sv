module fm_demod (
    input wire sys_clk,
    input wire sys_rst_n,

    // * AD接口
    input wire [7:0] ad_data,
    input wire ad_otr,
    output wire ad_clk,

    // * DA接口
    output wire da_clk,
    output wire [7:0] da_data,
    output wire [15:0] filter,
    output wire clk_150m
);

    // ========================= Clock & Reset =========================

    wire clk_30m;
    wire pll_locked;

    // * PLL 实例
    pll u_pll (
        .areset(~sys_rst_n),
        .inclk0(sys_clk),
        .c0(clk_30m),
        .c1(clk_150m),
        .locked(pll_locked)
    );

    wire rst_n = sys_rst_n & pll_locked;

    assign ad_clk = clk_30m;
    assign da_clk = clk_30m;

    // ========================= ADC 采样 & 差分处理 =========================

    reg signed [7:0] fm_in;
    always @(posedge clk_30m or negedge rst_n) begin
        if (!rst_n)
            fm_in <= 8'sd0;
        else
            fm_in <= ad_data - 8'd128;
    end

    reg signed [7:0] fm_delay;
    always @(posedge clk_30m or negedge rst_n) begin
        if (!rst_n)
            fm_delay <= 8'sd0;
        else
            fm_delay <= fm_in;
    end

    wire signed [7:0] diff;
    assign diff = fm_in - fm_delay;

    // ========================= 绝对值计算（时序逻辑） =========================

    reg [7:0] abs_diff;
    always @(posedge clk_30m or negedge rst_n) begin
        if (!rst_n)
            abs_diff <= 8'd0;
        else
            abs_diff <= (diff[7]) ? -diff : diff;
    end

    // ========================= 放大处理 + FIR输入准备 =========================

    wire [10:0] amplified_abs;
    assign amplified_abs = abs_diff <<< 4;  // 左移4位 ≈ x16 放大

    wire [7:0] abs_val;
    assign abs_val = amplified_abs[10:3];  // 截取中间8位用于滤波器输入

    // ========================= FIR 滤波器 =========================
    wire signed [15:0] fir_in;
    wire signed [15:0] fir_hp_out;
    wire signed [7:0] da_data_;
    FIR u_fir (
        .clk(clk_30m),
        .fir_in(ad_data - 8'd128),  // 输入为AD采样值减去128
        .fir_out(da_data_)
    );

    assign da_data = da_data_ + 8'd128;  // 取高8位作为DA输出

    // FIR_Highpass u_fir_hp (
    //     .clk(clk_30m),
    //     .fir_in(ad_data),
    //     .fir_out(fir_hp_out)
    // );

    // ========================= 输出处理（DA） =========================

    assign filter = fir_hp_out;  // debug 输出观察滤波结果

    wire signed [7:0] dac_data;
    assign dac_data = fir_hp_out[7:0]<<<5;         // 取高8位为DA输入
    // assign da_data  = dac_data ;     // 转为无符号格式给DA

endmodule
