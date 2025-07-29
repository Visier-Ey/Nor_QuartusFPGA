module loop_filter (
    input clk,
    input rst,                // 异步复位（低电平有效）
    input valid,              // 使能信号
    input signed [31:0] phase_error,  // 鉴相器输出的15位误差信号
    output reg signed [31:0] freq_ctrl // 输出给NCO的频率控制字
);

    // 环路滤波器参数（可根据实际需求调整）
    parameter Kp = 2;         // 比例增益（右移位数，相当于除以2^Kp）
    // ! 12 and 8
    parameter Ki = 8;         // 积分增益（右移位数，相当于除以2^Ki）
    parameter INIT_FREQ = 85899345;  // NCO初始频率控制字

    // 内部寄存器
    reg signed [31:0] integrator;  // 积分器累加值
    reg signed [31:0] prop_term;   // 比例项

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // 异步复位
            integrator <= INIT_FREQ;
            prop_term  <= 0;
            freq_ctrl  <= 0;
        end 
        else if (valid) begin
            // 比例项计算（相位误差 * Kp）
            prop_term <= phase_error >>> Kp;

            // 积分项计算（累加相位误差 * Ki）
            integrator <= integrator + (phase_error >>> Ki);

            // 总频率控制字 = 比例项 + 积分项
            freq_ctrl <= prop_term + integrator;
        end
    end

endmodule