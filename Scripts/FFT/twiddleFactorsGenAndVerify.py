import numpy as np
import matplotlib.pyplot as plt


def generate_optimized_twiddle_factors(N, bit_width=8):
    """
    生成优化的1024点FFT旋转因子

    参数:
        N: FFT点数
        bit_width: 旋转因子位宽

    返回:
        twiddle_real: 旋转因子实部(整数)
        twiddle_imag: 旋转因子虚部(整数)
    """
    n = np.arange(N)
    k = n.reshape((N, 1))

    # 计算精确的旋转因子
    angles = -2 * np.pi * k * n / N
    twiddle_real = np.cos(angles)
    twiddle_imag = np.sin(angles)

    # 优化量化方法 - 对称量化
    max_val = 2 ** (bit_width - 1) - 1
    twiddle_real = np.round(twiddle_real * max_val).astype(np.int32)
    twiddle_imag = np.round(twiddle_imag * max_val).astype(np.int32)

    return twiddle_real, twiddle_imag


def write_to_mif(twiddle_real, twiddle_imag, filename, bit_width=8):
    """
    将旋转因子写入MIF文件

    参数:
        twiddle_real: 旋转因子实部
        twiddle_imag: 旋转因子虚部
        filename: 输出的MIF文件名
        bit_width: 数据位宽
    """
    N = twiddle_real.shape[0]
    max_addr = N * N - 1
    max_val = 2 ** bit_width - 1

    with open(filename, 'w') as f:
        # 写入MIF文件头
        f.write("-- FFT Twiddle Factors Memory Initialization File\n")
        f.write(f"-- Generated for {N}-point FFT with {bit_width}-bit precision\n\n")
        f.write(f"DEPTH = {N * N};  -- The size of memory in words\n")
        f.write(f"WIDTH = {bit_width * 2};  -- The size of data in bits\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = HEX;\n")
        f.write("CONTENT BEGIN\n")

        # 写入数据内容
        addr = 0
        for i in range(N):
            for j in range(N):
                # 获取实部和虚部值(转换为无符号)
                re = twiddle_real[i, j] & 0xFF
                im = twiddle_imag[i, j] & 0xFF

                # 组合实部和虚部(实部在高位，虚部在低位)
                combined = (re << bit_width) | im

                # 写入到文件
                f.write(f"{addr} : {combined:04X};\n")
                addr += 1

        f.write("END;\n")

    print(f"Successfully wrote twiddle factors to {filename}")


def write_separate_mif(twiddle_real, twiddle_imag, real_filename, imag_filename, bit_width=8):
    """
    将实部和虚部分别写入两个MIF文件

    参数:
        twiddle_real: 旋转因子实部
        twiddle_imag: 旋转因子虚部
        real_filename: 实部MIF文件名
        imag_filename: 虚部MIF文件名
        bit_width: 数据位宽
    """
    N = twiddle_real.shape[0]

    # 写入实部文件
    with open(real_filename, 'w') as f:
        f.write("-- FFT Twiddle Factors (Real Part)\n")
        f.write(f"-- Generated for {N}-point FFT with {bit_width}-bit precision\n\n")
        f.write(f"DEPTH = {N * N};\n")
        f.write(f"WIDTH = {bit_width};\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = HEX;\n")
        f.write("CONTENT BEGIN\n")

        addr = 0
        for i in range(N):
            for j in range(N):
                val = twiddle_real[i, j] & 0xFF
                f.write(f"{addr} : {val:02X};\n")
                addr += 1

        f.write("END;\n")

    # 写入虚部文件
    with open(imag_filename, 'w') as f:
        f.write("-- FFT Twiddle Factors (Imaginary Part)\n")
        f.write(f"-- Generated for {N}-point FFT with {bit_width}-bit precision\n\n")
        f.write(f"DEPTH = {N * N};\n")
        f.write(f"WIDTH = {bit_width};\n")
        f.write("ADDRESS_RADIX = DEC;\n")
        f.write("DATA_RADIX = HEX;\n")
        f.write("CONTENT BEGIN\n")

        addr = 0
        for i in range(N):
            for j in range(N):
                val = twiddle_imag[i, j] & 0xFF
                f.write(f"{addr} : {val:02X};\n")
                addr += 1

        f.write("END;\n")

    print(f"Successfully wrote real part to {real_filename}")
    print(f"Successfully wrote imaginary part to {imag_filename}")

def generate_test_signal(N, signal_freq=100, fs=1024, bit_width=8):
    """
    生成优化的测试信号

    参数:
        N: 点数
        signal_freq: 信号频率
        fs: 采样率
        bit_width: ADC位宽

    返回:
        signal_quantized: 量化后的信号
    """
    t = np.arange(N) / fs
    signal = np.sin(2 * np.pi * signal_freq * t)

    # 优化量化 - 添加抖动(dithering)减少量化噪声
    dither = np.random.uniform(-0.5, 0.5, N)
    signal_dithered = signal * (2 ** (bit_width - 1) - 1) + dither

    # 量化并确保在范围内
    signal_quantized = np.clip(np.round(signal_dithered), -2 ** (bit_width - 1), 2 ** (bit_width - 1) - 1)
    return signal_quantized.astype(np.int32)


def optimized_fft(signal, twiddle_real, twiddle_imag, N):
    """
    优化的FFT实现

    参数:
        signal: 输入信号
        twiddle_real: 旋转因子实部
        twiddle_imag: 旋转因子虚部
        N: FFT点数

    返回:
        spectrum: FFT结果
    """
    spectrum = np.zeros(N, dtype=np.complex128)
    scale_factor = 1.0 / (2 ** 7)  # 8位旋转因子的缩放因子

    for k in range(N):
        for n in range(N):
            # 使用预计算的旋转因子并考虑量化效应
            re = twiddle_real[k, n] * scale_factor
            im = twiddle_imag[k, n] * scale_factor
            spectrum[k] += signal[n] * (re + 1j * im)

    return spectrum


def analyze_spectrum(spectrum, fs=1024, signal_freq=100):
    """
    详细分析频谱

    参数:
        spectrum: FFT结果
        fs: 采样率
        signal_freq: 信号频率
    """
    N = len(spectrum)
    freq = np.linspace(0, fs / 2, N // 2)
    magnitude = np.abs(spectrum[:N // 2]) / (N / 2)

    plt.figure(figsize=(14, 6))

    # 绘制整个频谱
    plt.subplot(1, 2, 1)
    plt.plot(freq, 20 * np.log10(magnitude + 1e-12))
    plt.title('Full Spectrum (dB Scale)')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)

    # 绘制信号频率附近的细节
    plt.subplot(1, 2, 2)
    idx = np.abs(freq - signal_freq).argmin()
    window = 20  # 显示信号频率附近的+/-20个bin
    low = max(0, idx - window)
    high = min(len(freq), idx + window)

    plt.plot(freq[low:high], 20 * np.log10(magnitude[low:high] + 1e-12))
    plt.title(f'Spectrum Detail around {signal_freq}Hz')
    plt.xlabel('Frequency (Hz)')
    plt.ylabel('Magnitude (dB)')
    plt.grid(True)

    plt.tight_layout()
    plt.show()

    # 计算并显示SNR
    signal_bin = idx
    noise_bins = np.concatenate([np.arange(low, signal_bin - 2), np.arange(signal_bin + 3, high)])
    signal_power = magnitude[signal_bin] ** 2
    noise_power = np.mean(magnitude[noise_bins] ** 2)
    snr = 10 * np.log10(signal_power / noise_power)
    print(f"Estimated SNR: {snr:.2f} dB")


# 主程序
if __name__ == "__main__":
    N = 1024
    bit_width = 8
    signal_freq = 100
    fs = 1024

    print("Generating optimized twiddle factors...")
    twiddle_real, twiddle_imag = generate_optimized_twiddle_factors(N, bit_width)


    print("\nWriting combined twiddle factors to MIF file...")
    write_to_mif(twiddle_real, twiddle_imag, "twiddle_factors_combined.mif", bit_width)


    print("\nWriting separate twiddle factors to MIF files...")
    write_separate_mif(twiddle_real, twiddle_imag,
                       "twiddle_real.mif", "twiddle_imag.mif", bit_width)

    print("Generating test signal with dithering...")
    test_signal = generate_test_signal(N, signal_freq, fs, bit_width)

    print("Performing FFT with generated twiddle factors...")
    spectrum = optimized_fft(test_signal, twiddle_real, twiddle_imag, N)

    print("Analyzing spectrum...")
    analyze_spectrum(spectrum, fs, signal_freq)