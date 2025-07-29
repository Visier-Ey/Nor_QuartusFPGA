import numpy as np
from scipy.signal import firwin, freqz
import matplotlib.pyplot as plt

def generate_signed_fir(num_taps=15, cutoff=0.2, coeff_max=1024,
                       input_width=8, output_width=16):
    """
    生成支持任意输入/输出位宽的有符号FIR滤波器 Verilog 代码（修复负数问题）

    参数:
        num_taps (int): 滤波器阶数（必须为奇数）
        cutoff (float): 归一化截止频率（0~1）
        coeff_max (int): 系数量化最大绝对值
        input_width (int): 输入数据位宽（8或16）
        output_width (int): 输出数据位宽（8或16）

    返回:
        tuple: (verilog_code, quantized_coeffs, original_coeffs)
    """
    # 参数检查
    if num_taps % 2 == 0:
        num_taps += 1
        print(f"注意：自动调整为奇数阶 {num_taps}")

    # 生成滤波器系数
    coeffs = firwin(num_taps, cutoff, window='hamming')
    scale_factor = coeff_max / np.max(np.abs(coeffs))
    quantized_coeffs = np.round(coeffs * scale_factor).astype(int)

    # 计算位宽
    unique_taps = (num_taps + 1) // 2
    coeff_width = int(np.ceil(np.log2(coeff_max + 1))) + 1  # +1 for sign
    product_width = input_width + coeff_width
    sum_width = product_width + int(np.ceil(np.log2(unique_taps))) + 1
    shift_bits = max(sum_width - output_width, 0)

    # Verilog代码生成
    verilog_code = [
        f"// {num_taps}阶有符号FIR滤波器",
        f"// 截止频率={cutoff}π，输入={input_width}位，输出={output_width}位",
        f"module FIR (",
        f"    input clk,",
        f"    input signed [{input_width-1}:0] fir_in,",
        f"    output signed [{output_width-1}:0] fir_out",
        f");",
        f"    reg signed [{input_width-1}:0] delay_line [0:{num_taps - 1}];",
        "",
        f"    // 量化系数（自动处理负数）"
    ]

    # 生成系数定义（修复负数问题）
    for i in range(unique_taps):
        if quantized_coeffs[i] >= 0:
            verilog_code.append(f"    localparam signed [{coeff_width-1}:0] coeff{i} = {coeff_width}'sd{quantized_coeffs[i]};")
        else:
            # 计算负数的补码表示
            twos_complement = (1 << coeff_width) + quantized_coeffs[i]
            verilog_code.append(f"    localparam signed [{coeff_width-1}:0] coeff{i} = {coeff_width}'sd{twos_complement};")

    # 生成延迟线和乘法逻辑
    verilog_code.extend([
        "",
        f"    always @(posedge clk) begin",
        f"        integer i;",
        f"        for (i = {num_taps - 1}; i > 0; i = i - 1)",
        f"            delay_line[i] <= delay_line[i-1];",
        f"        delay_line[0] <= fir_in;",
        f"    end",
        "",
        f"    wire signed [{product_width-1}:0] " + ", ".join([f"product{i}" for i in range(unique_taps)]) + ";"
    ])

    # 生成乘法器
    for i in range(unique_taps):
        if i == (num_taps // 2):
            verilog_code.append(f"    assign product{i} = delay_line[{i}] * coeff{i};")
        else:
            verilog_code.append(f"    assign product{i} = (delay_line[{i}] + delay_line[{num_taps - 1 - i}]) * coeff{i};")

    # 生成求和和输出
    verilog_code.extend([
        "",
        f"    wire signed [{sum_width-1}:0] sum = " + " + ".join([f"product{i}" for i in range(unique_taps)]) + ";",
        f"    assign fir_out = sum[{sum_width-1}:{shift_bits}];",
        "endmodule"
    ])

    return "\n".join(verilog_code), quantized_coeffs, coeffs

def plot_fir_response(coeffs, quantized_coeffs, cutoff, fs=1.0):
    """绘制滤波器频率响应"""
    w, h = freqz(coeffs, worN=8000, fs=fs)
    w_q, h_q = freqz(quantized_coeffs / np.max(np.abs(quantized_coeffs)) * np.max(np.abs(coeffs)),
                     worN=8000, fs=fs)

    plt.figure(figsize=(12, 6))
    plt.plot(w, 20 * np.log10(np.abs(h)), label='Original coefficient', color='blue')
    plt.plot(w_q, 20 * np.log10(np.abs(h_q)), '--', label='Quantized coefficient', color='red')
    plt.axvline(cutoff, color='green', linestyle=':', label=f'cut-off frequency={cutoff}π')
    plt.xlabel('Frequency (×π rad/sample)')
    plt.ylabel('Magnitude (dB)')
    plt.title('FIR Filter Frequency Response')
    plt.grid(True)
    plt.legend()
    plt.xlim(0, 0.5)
    plt.ylim(-100, 5)
    plt.show()

def verify_fir(coeffs, quantized_coeffs, coeff_max):
    """验证量化误差"""
    normalized_coeffs = coeffs / np.max(np.abs(coeffs)) * coeff_max
    error = np.abs(normalized_coeffs - quantized_coeffs)

    print(f"\n量化误差统计:")
    print(f"  最大误差: {np.max(error):.2f}")
    print(f"  平均误差: {np.mean(error):.2f}")
    print(f"  误差标准差: {np.std(error):.2f}")

    plt.figure(figsize=(12, 4))
    plt.plot(coeffs, 'o-', label='Original coefficient', color='blue')
    plt.plot(quantized_coeffs / coeff_max * np.max(np.abs(coeffs)), 'x--', label='Quantized coefficient', color='red')
    plt.title('Filter Coefficient Comparison (Raw vs Quantization)')
    plt.xlabel('Tap Number ')
    plt.ylabel('Coefficient value')
    plt.grid(True)
    plt.legend()
    plt.show()

# 示例使用
if __name__ == "__main__":
    num_taps = 127
    fs = 100e6  # 采样率 100 MHz
    cutoff_hz = 100e3  # 截止频率 100 kHz

    # 计算归一化截止频率，传给原来的函数
    cutoff = cutoff_hz / (fs / 2)

    coeff_max = 65535
    input_width = 32
    output_width = 32

    verilog_code, quantized_coeffs, original_coeffs = generate_signed_fir(
        num_taps=num_taps,
        cutoff=cutoff,
        coeff_max=coeff_max,
        input_width=input_width,
        output_width=output_width
    )

    print(verilog_code)

    print("生成的Verilog代码：\n")
    print(verilog_code)

    print("\n实际生成系数：")
    print(quantized_coeffs)

    # 验证和绘图
    verify_fir(original_coeffs, quantized_coeffs, coeff_max)
    plot_fir_response(original_coeffs, quantized_coeffs, cutoff)