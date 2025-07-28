import numpy as np
import matplotlib.pyplot as plt

def read_mif(filename, q_format='q1.7'):
    """读取 Q1.7 格式的 Twiddle MIF 文件"""
    def q7_to_float(val):
        val = val if val < 128 else val - 256
        return val / 128.0

    with open(filename, 'r') as f:
        lines = f.readlines()

    data = []
    for line in lines:
        if ':' in line:
            hex_str = line.split(':')[1].split(';')[0].strip()
            value = int(hex_str, 16)
            data.append(q7_to_float(value))
    return np.array(data)

def verify_twiddle_vs_numpy_fft():
    N = 1024
    fs = 1e6
    f_sig = 50e3

    t = np.arange(N) / fs
    signal = np.sin(2 * np.pi * f_sig * t)  # 无噪声纯正弦

    fft_np = np.fft.fft(signal)
    freq = np.fft.fftfreq(N, 1/fs)
    mag_db = 20 * np.log10(np.abs(fft_np) + 1e-6)

    plt.figure(figsize=(10,5))
    plt.plot(freq[:N//2], mag_db[:N//2])
    plt.title(f"Signal Spectrum via NumPy FFT (Signal @ {f_sig/1e3:.1f} kHz)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid()
    plt.show()

    # 可选：打印第几个 twiddle 对应最大值
    max_bin = np.argmax(np.abs(fft_np[:N//2]))
    print(f"最大频率分量在 bin {max_bin}, 频率 = {freq[max_bin]} Hz")

    # 验证 twiddle 实值（角度检查）
    tw_real = read_mif("twiddle_real.mif")
    tw_imag = read_mif("twiddle_imag.mif")
    angle = 2 * np.pi * max_bin / N
    expected_cos = np.cos(-angle)
    expected_sin = np.sin(-angle)
    err_cos = abs(tw_real[max_bin] - expected_cos)
    err_sin = abs(tw_imag[max_bin] - expected_sin)

    print(f"Twiddle[{max_bin}]: cos ≈ {tw_real[max_bin]:.4f}, 正确值={expected_cos:.4f}, 误差={err_cos:.4e}")
    print(f"Twiddle[{max_bin}]: sin ≈ {tw_imag[max_bin]:.4f}, 正确值={expected_sin:.4f}, 误差={err_sin:.4e}")

if __name__ == "__main__":
    verify_twiddle_vs_numpy_fft()
