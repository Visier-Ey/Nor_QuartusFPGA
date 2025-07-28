import numpy as np

def float_to_q7(val):
    """将浮点数转换为 Q1.7 格式的整数（范围 -128 到 +127）"""
    val = np.clip(val, -1.0, 0.9921875)  # Q1.7最大值 = (127/128)
    return int(np.round(val * 128)) & 0xFF  # 转为 8-bit 无符号整数（用于 MIF）

def write_mif(filename, data, width=8, depth=None):
    if depth is None:
        depth = len(data)

    with open(filename, 'w') as f:
        f.write(f"WIDTH={width};\n")
        f.write(f"DEPTH={depth};\n\n")
        f.write("ADDRESS_RADIX=UNS;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")
        for addr, val in enumerate(data):
            f.write(f"{addr:4d} : {val:02X};\n")
        f.write("END;\n")

def generate_twiddles(N):
    """生成 N/2 个旋转因子（由于对称性）"""
    twiddles_real = []
    twiddles_imag = []
    for k in range(N // 2):
        angle = -2 * np.pi * k / N
        c = np.cos(angle)
        s = np.sin(angle)
        twiddles_real.append(float_to_q7(c))
        twiddles_imag.append(float_to_q7(s))
    return twiddles_real, twiddles_imag

if __name__ == "__main__":
    FFT_POINTS = 1024  # 支持其他点数，如 512, 256 等
    real_vals, imag_vals = generate_twiddles(FFT_POINTS)

    write_mif("twiddle_real.mif", real_vals, width=8, depth=FFT_POINTS // 2)
    write_mif("twiddle_imag.mif", imag_vals, width=8, depth=FFT_POINTS // 2)

    print("生成完成：twiddle_real.mif 和 twiddle_imag.mif")
