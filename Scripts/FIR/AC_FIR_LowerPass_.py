import numpy as np
from scipy.signal import firwin, freqz
import matplotlib.pyplot as plt

def generate_signed_fir(num_taps=15, cutoff=0.2, coeff_max=32767, input_width=16):
    """
    生成支持更高位输入的有符号FIR滤波器 Verilog 代码

    参数:
        num_taps (int): 滤波器阶数（必须为奇数）
        cutoff (float): 归一化截止频率（0~1）
        coeff_max (int): 系数量化最大绝对值（例如 32767 对应 16bit 有符号）
        input_width (int): 输入信号位宽（默认 16 位）
    """
    if num_taps % 2 == 0:
        num_taps += 1
        print(f"注意：自动调整为奇数阶 {num_taps}")

    coeffs = firwin(num_taps, cutoff, window='hamming')
    scale_factor = coeff_max / np.max(np.abs(coeffs))
    quantized_coeffs = np.round(coeffs * scale_factor).astype(int)
    unique_taps = (num_taps + 1) // 2

    coeff_width = int(np.ceil(np.log2(coeff_max + 1))) + 1
    product_width = input_width + coeff_width
    sum_width = product_width + int(np.ceil(np.log2(unique_taps))) + 1
    output_width = 16
    shift_bits = max(sum_width - output_width, 0)

    verilog_code = [
        f"// {num_taps}阶有符号FIR滤波器，截止频率={cutoff}π，输入{input_width}位",
        f"module FIR16 (",
        f"    input clk,",
        f"    input signed [{input_width-1}:0] fir_in,",
        f"    output signed [{output_width-1}:0] fir_out",
        f");",
        f"    reg signed [{input_width-1}:0] delay_line [0:{num_taps - 1}];",
        "",
        f"    // 量化系数（最大绝对值={coeff_max}）"
    ]

    for i in range(unique_taps):
        verilog_code.append(f"    localparam signed [{coeff_width-1}:0] coeff{i} = {coeff_width}'sd{quantized_coeffs[i]};")

    verilog_code.extend([
        "",
        "    // 移位寄存器实现",
        "    always @(posedge clk) begin",
        f"        integer i;",
        f"        for (i = {num_taps - 1}; i > 0; i = i - 1)",
        "            delay_line[i] <= delay_line[i-1];",
        "        delay_line[0] <= fir_in;",
        "    end",
        ""
    ])

    verilog_code.append(f"    // 有符号乘法和累加")
    verilog_code.append(f"    wire signed [{product_width-1}:0] " + ", ".join([f"product{i}" for i in range(unique_taps)]) + ";")

    for i in range(unique_taps):
        if i == (num_taps // 2):
            verilog_code.append(f"    assign product{i} = delay_line[{i}] * coeff{i};")
        else:
            verilog_code.append(f"    assign product{i} = (delay_line[{i}] + delay_line[{num_taps - 1 - i}]) * coeff{i};")

    verilog_code.append("")
    verilog_code.append(f"    wire signed [{sum_width-1}:0] sum = " + " + ".join([f"product{i}" for i in range(unique_taps)]) + ";")
    verilog_code.append(f"    assign fir_out = sum[{sum_width-1}:{shift_bits}];  // 右移{shift_bits}位，输出{output_width}位")
    verilog_code.append("endmodule")

    return "\n".join(verilog_code), quantized_coeffs, coeffs

def plot_fir_response(coeffs, quantized_coeffs, cutoff, fs=1.0):
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
    num_taps = 63
    cutoff = 0.001  # 0.001 × π
    coeff_max = 32767
    input_width = 16

    verilog_code, quantized_coeffs, original_coeffs = generate_signed_fir(
        num_taps=num_taps,
        cutoff=cutoff,
        coeff_max=coeff_max,
        input_width=input_width
    )

    print("生成的Verilog代码：\n")
    print(verilog_code)

    print("\n实际生成系数：")
    print(quantized_coeffs)

    verify_fir(original_coeffs, quantized_coeffs, coeff_max)
    plot_fir_response(original_coeffs, quantized_coeffs, cutoff)
