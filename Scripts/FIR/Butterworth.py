import numpy as np
from scipy.signal import butter

def generate_butterworth_filter(order=4, cutoff=0.1, coeff_bits=16, input_bits=16, output_bits=16, filter_type='low'):
    b, a = butter(order, cutoff, btype=filter_type, analog=False, output='ba')

    scale = 2 ** (coeff_bits - 1) - 1
    b_q = np.round(b * scale).astype(int)
    a_q = np.round(a * scale).astype(int)

    max_len = max(len(b_q), len(a_q))
    b_q = np.pad(b_q, (0, max_len - len(b_q)))
    a_q = np.pad(a_q, (0, max_len - len(a_q)))

    code = [
        f"// Butterworth {filter_type}-pass滤波器, 阶数={order}, 截止={cutoff}π",
        "module butterworth_filter(",
        "    input clk,",
        "    input rst,",
        f"    input signed [{input_bits-1}:0] din,",
        f"    output signed [{output_bits-1}:0] dout",
        ");",
        ""
    ]

    # 系数
    for i, val in enumerate(b_q):
        code.append(f"localparam signed [{coeff_bits-1}:0] b{i} = {coeff_bits}'sd{val};")
    for i in range(1, len(a_q)):
        val = -a_q[i]  # 注意符号变换
        code.append(f"localparam signed [{coeff_bits-1}:0] a{i} = {coeff_bits}'sd{val};")
    code.append("")

    # 输入/输出寄存器
    code += [
        f"reg signed [{input_bits-1}:0] x[0:{max_len-1}];",
        f"reg signed [{output_bits-1}:0] y[1:{max_len-1}];",
        "",
        "integer i;",
        "always @(posedge clk or posedge rst) begin",
        "    if (rst) begin"
    ] + [
        f"        x[{i}] <= 0;" for i in range(max_len)
    ] + [
        f"        y[{i}] <= 0;" for i in range(1, max_len)
    ] + [
        "    end else begin"
    ] + [
        f"        x[{i}] <= x[{i-1}];" for i in reversed(range(1, max_len))
    ] + [
        "        x[0] <= din;",
        "        y[1] <= y_temp;"
    ] + [
        f"        y[{i}] <= y[{i-1}];" for i in reversed(range(2, max_len))
    ] + [
        "    end",
        "end",
        ""
    ]

    # 运算
    b_terms = " + ".join([f"x[{i}]*b{i}" for i in range(max_len)])
    a_terms = " + ".join([f"y[{i}]*a{i}" for i in range(1, max_len)])
    code.append("wire signed [31:0] y_temp;")
    code.append(f"assign y_temp = {b_terms} + {a_terms};")

    shift = coeff_bits - 1
    code.append(f"assign dout = y_temp[{shift + output_bits - 1}:{shift}];")
    code.append("endmodule")

    return "\n".join(code)

# 示例生成
verilog_module = generate_butterworth_filter(order=4, cutoff=0.05)
print(verilog_module)
