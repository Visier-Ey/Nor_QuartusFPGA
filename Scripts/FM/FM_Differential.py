import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import lfilter
from scipy.signal import firwin
# 参数
fs = 30e6         # 采样率 30MHz
t_end = 0.01     # 1ms仿真时间
fc = 1e6          # 载波频率 1MHz
fm = 1e3          # 基带频率 10kHz
freq_dev = 5e4

# 时间序列
t = np.arange(0, t_end, 1/fs)

# 基带信号（音频调制信号）
baseband = np.sin(2 * np.pi * fm * t)

# 瞬时相位 (载波相位 + 调制项)
inst_phase = 2 * np.pi * (fc * t + (freq_dev / fm) * baseband)

# FM调制信号
fm_signal = np.sin(inst_phase)

# 模拟AD采样：无符号8-bit量化 [-128,127]映射成[0,255]
adc_data = (fm_signal * 100 + 128).astype(np.uint8)

# 转为有符号 [-128,127]
fm_in = adc_data.astype(np.int16) - 128

# 差分解调（模拟你的 Verilog 差分器）
diff = np.zeros_like(fm_in)
diff[1:] = fm_in[1:] - fm_in[:-1]

# 绝对值并放大（左移4位 ~ 乘16）
abs_diff = np.abs(diff) * 16

# 限幅到8位
abs_val = np.clip(abs_diff >> 3, 0, 255).astype(np.uint8)  # 这里模拟你的截位abs_val

# 简单FIR滤波器（例如低通滤波）
# FIR系数（简单低通）

numtaps = 127
cutoff_hz = 1e5  # 比如1MHz截止频率
fir_coefs = firwin(numtaps, cutoff_hz/(fs/2))  # 归一化截止频率：截止频率/奈奎斯特频率

fir_out = lfilter(fir_coefs, 1, abs_val)

# 缩放到16位并取高8位，模拟你fir_out[15:8]
fir_out_scaled = (fir_out * 256).astype(np.int16)  # 放大模拟
dac_data = np.clip(fir_out_scaled >> 8, -128, 127)

# DA输出，转回无符号8位
da_data = dac_data + 128

# 画图对比
plt.figure(figsize=(12, 10))
N = len(t)

plt.subplot(4,1,1)
plt.plot(t[:N]*1e6, baseband[:N])
plt.title('Baseband Signal (10kHz)')
plt.ylabel('Amplitude')
plt.grid()

plt.subplot(4,1,2)
plt.plot(t[:N]*1e6, fm_signal[:N])
plt.title('FM Modulated Signal (Carrier 1MHz)')
plt.ylabel('Amplitude')
plt.grid()

plt.subplot(4,1,3)
plt.plot(t[:N]*1e6, abs_val[:N])
plt.title('Demodulator Abs Diff Signal')
plt.ylabel('Amplitude')
plt.grid()

plt.subplot(4,1,4)
plt.plot(t[:N]*1e6, da_data[:N])
plt.title('DA Output Signal (Filtered)')
plt.ylabel('Amplitude')
plt.xlabel('Time (us)')
plt.grid()

plt.tight_layout()
plt.show()
