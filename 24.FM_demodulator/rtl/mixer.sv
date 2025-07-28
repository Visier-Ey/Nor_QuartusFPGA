module mixer (
    input wire clk,          // 系统时钟
    input wire rst,          // 异步复位
    input wire signed [7:0] adc_data,  // 8位ADC输入（补码，-128 ~ +127）
    input wire signed [7:0] nco_sin,   // 8位NCO正弦输出（-128 ~ +127）
    input wire signed [7:0] nco_cos,   // 8位NCO余弦输出
    output reg signed [15:0] I_out,    // 16位I路输出（可截断或保留）
    output reg signed [15:0] Q_out     // 16位Q路输出
);

    // 8x8乘法器输出（16位）
    wire signed [15:0] I_product = adc_data * nco_cos;  // I = ADC × cos(θ)
    wire signed [15:0] Q_product = adc_data * nco_sin;  // Q = ADC × sin(θ)

    // 寄存器输出（可选截断或保留全部位）
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            I_out <= 16'd0;
            Q_out <= 16'd0;
        end else begin
            I_out <= I_product;  // 16位输出（可进一步优化）
            Q_out <= Q_product;
        end
    end

endmodule