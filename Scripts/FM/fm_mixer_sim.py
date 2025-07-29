import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# --- 模拟参数 ---
fs = 100e6            # 采样率
t = np.arange(0, 100000) / fs  # 1ms仿真时间
fc = 1e6              # 载波1MHz
kf = 20e3            # 频偏系数20kHz
fm = 10e3              # 基带10kHz

# --- 基带信号 ---
baseband = np.sin(2 * np.pi * fm * t)

# --- FM调制 ---
phase = 2 * np.pi * fc * t + 2 * np.pi * kf * np.cumsum(baseband) / fs
fm_signal = np.cos(phase)

# --- NCO输出 ---
nco_cos = np.cos(2 * np.pi * fc * t)
nco_sin = np.sin(2 * np.pi * fc * t)

# --- 混频 ---
mix_I = fm_signal * nco_cos
mix_Q = fm_signal * nco_sin

# --- 设计低通滤波器 (截止频率设为100kHz) ---
nyq = 0.5 * fs
numtaps = 127  # FIR滤波器长度（滤波器阶数+1），奇数比较常用
fir_cutoff = 100e3  # 截止频率，和之前一致
fir_b = signal.firwin(numtaps, fir_cutoff / nyq)  # 设计低通FIR滤波器，默认汉明窗

filtered_I = signal.lfilter(fir_b, [1.0], mix_I)
filtered_Q = signal.lfilter(fir_b, [1.0], mix_Q)

# --- 绘图 ---
plt.figure(figsize=(12, 12))

# 基带信号
plt.subplot(6, 1, 1)
plt.plot(t * 1e3, baseband)
plt.title("Baseband Signal (1kHz)")
plt.grid()

# FM信号
plt.subplot(6, 1, 2)
plt.plot(t * 1e3, fm_signal, color='purple')
plt.title("FM Signal")
plt.grid()

# 混频后I/Q（滤波前）
plt.subplot(6, 1, 3)
plt.plot(t * 1e3, mix_I, label="I (pre-filter)", color='orange', alpha=0.7)
plt.plot(t * 1e3, mix_Q, label="Q (pre-filter)", color='green', alpha=0.7)
plt.ylabel("Amplitude")
plt.title("Mixed I/Q Signals (Before Filtering)")
plt.legend()
plt.grid()

# 混频后I/Q（滤波后）
plt.subplot(6, 1, 4)
plt.plot(t * 1e3, filtered_I, label="I (filtered)", color='orange')
plt.plot(t * 1e3, filtered_Q, label="Q (filtered)", color='green')
plt.ylabel("Amplitude")
plt.title("Filtered I/Q Signals")
plt.legend()
plt.grid()

# 滤波前后对比（I路）
plt.subplot(6, 1, 5)
plt.plot(t * 1e3, mix_I, label="Original I", color='orange', alpha=0.3)
plt.plot(t * 1e3, filtered_I, label="Filtered I", color='red')
plt.ylabel("Amplitude")
plt.title("I Signal Comparison")
plt.legend()
plt.grid()

# 滤波前后对比（Q路）
plt.subplot(6, 1, 6)
plt.plot(t * 1e3, mix_Q, label="Original Q", color='green', alpha=0.3)
plt.plot(t * 1e3, filtered_Q, label="Filtered Q", color='blue')
plt.ylabel("Amplitude")
plt.xlabel("Time (ms)")
plt.title("Q Signal Comparison")
plt.legend()
plt.grid()

plt.tight_layout()
plt.show()



# --- 解调部分（相位差分）---
# 计算相位：phi = arctan2(Q, I)
phi = np.arctan2(filtered_Q, filtered_I)

# 相位解缠绕（处理2π跳变）
phi_unwrapped = np.unwrap(phi)

# 计算相位差分（近似导数）
delta_phi = np.diff(phi_unwrapped)

# 由于差分少一个点，对齐时间轴
t_diff = t[:-1]

# --- 绘图扩展 ---
plt.figure(figsize=(12, 14))

# 基带信号
plt.subplot(7, 1, 1)
plt.plot(t * 1e3, baseband)
plt.title("Baseband Signal (1kHz)")
plt.grid()

# FM信号
plt.subplot(7, 1, 2)
plt.plot(t * 1e3, fm_signal, color='purple')
plt.title("FM Signal")
plt.grid()

# 滤波后I/Q
plt.subplot(7, 1, 3)
plt.plot(t * 1e3, filtered_I, label="I", color='orange')
plt.plot(t * 1e3, filtered_Q, label="Q", color='green')
plt.title("Filtered I/Q Signals")
plt.legend()
plt.grid()

# 瞬时相位
plt.subplot(7, 1, 4)
plt.plot(t * 1e3, phi, label="Wrapped Phase", color='red', alpha=0.5)
plt.plot(t * 1e3, phi_unwrapped, label="Unwrapped Phase", color='blue')
plt.title("Phase (arctan2(Q/I))")
plt.legend()
plt.grid()

# 相位差分（解调输出）
plt.subplot(7, 1, 5)
plt.plot(t_diff * 1e3, delta_phi, color='darkviolet')
plt.title("Phase Difference (Demodulated Output)")
plt.grid()

# 解调信号 vs 原始基带
plt.subplot(7, 1, 6)
# 归一化后对比
demod_normalized = delta_phi / np.max(np.abs(delta_phi))
baseband_normalized = baseband[:-1] / np.max(np.abs(baseband[:-1]))
plt.plot(t_diff * 1e3, demod_normalized, label="Demodulated", color='black')
plt.plot(t_diff * 1e3, baseband_normalized, '--', label="Original Baseband", alpha=0.7)
plt.title("Normalized Comparison")
plt.legend()
plt.grid()

# 频谱分析（验证解调效果）
plt.subplot(7, 1, 7)
freq = np.fft.fftfreq(len(delta_phi), 1/fs)[:len(delta_phi)//2]
fft_demod = np.abs(np.fft.fft(delta_phi)[:len(delta_phi)//2])
plt.plot(freq / 1e3, 20 * np.log10(fft_demod + 1e-12))  # 避免log(0)
plt.xlim([0, 10])  # 聚焦在0-10kHz
plt.title("Demodulated Signal Spectrum")
plt.xlabel("Frequency (kHz)")
plt.grid()

plt.tight_layout()
plt.show()