module CORDIC (
    input         clk,
    input         rst_n,
    input         i_valid,          // 输入有效信号
    input  [23:0] i_data_i,         // 24位有符号 I 分量
    input  [23:0] i_data_q,         // 24位有符号 Q 分量
    output        o_valid,          // 输出有效信号
    output [15:0] o_phase,          // 相位（Q1.15格式，-π到π）
    output [15:0] o_magnitude       // 幅值（可选）
);

// --- CORDIC 参数 ---
parameter WIDTH = 24;               // 输入位宽
parameter ITER = 16;                // 迭代次数
reg signed [WIDTH-1:0] atan_table [0:ITER-1]; // Arctan 表

// --- 初始化 Arctan 表 ---
initial begin
    atan_table[0]  = 24'b001000000000000000000000;  // arctan(1/2^0)
    atan_table[1]  = 24'b000100101110010000000000;  // arctan(1/2^1)
    // ... 填充其他 atan_table 值（根据精度需求）
end

// --- CORDIC 迭代变量 ---
reg signed [WIDTH-1:0] x [0:ITER];
reg signed [WIDTH-1:0] y [0:ITER];
reg signed [WIDTH-1:0] z [0:ITER];  // 相位累加器

// --- 流水线控制 ---
reg [ITER:0] valid_pipe;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid_pipe <= 0;
    else valid_pipe <= {valid_pipe[ITER-1:0], i_valid};
end
assign o_valid = valid_pipe[ITER];

// --- CORDIC 迭代 ---
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        x[0] <= 0; y[0] <= 0; z[0] <= 0;
    end else if (i_valid) begin
        x[0] <= i_data_i;  // 初始化 I
        y[0] <= i_data_q;  // 初始化 Q
        z[0] <= 0;         // 相位初始化为 0
    end

    for (int i = 0; i < ITER; i++) begin
        if (!rst_n) begin
            x[i+1] <= 0; y[i+1] <= 0; z[i+1] <= 0;
        end else if (valid_pipe[i]) begin
            if (y[i] >= 0) begin
                x[i+1] <= x[i] + (y[i] >>> i);
                y[i+1] <= y[i] - (x[i] >>> i);
                z[i+1] <= z[i] + atan_table[i];
            end else begin
                x[i+1] <= x[i] - (y[i] >>> i);
                y[i+1] <= y[i] + (x[i] >>> i);
                z[i+1] <= z[i] - atan_table[i];
            end
        end
    end
end

// --- 输出相位和幅值 ---
assign o_phase     = z[ITER][WIDTH-1:WIDTH-16];  // 取高16位作为相位
assign o_magnitude = x[ITER][WIDTH-1:WIDTH-16];  // 幅值（可选）
endmodule