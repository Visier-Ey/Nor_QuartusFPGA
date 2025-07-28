import numpy as np
import matplotlib.pyplot as plt
from scipy import signal


class NCO:
    """数字控制振荡器(NCO)"""

    def __init__(self, sample_rate, initial_freq=0.0):
        self.sample_rate = sample_rate
        self.phase = 0.0
        self.freq = initial_freq
        self.phase_increment = 2 * np.pi * self.freq / self.sample_rate

    def update(self, freq_ctrl):
        """更新频率并生成正交输出"""
        self.freq = freq_ctrl
        self.phase_increment = 2 * np.pi * self.freq / self.sample_rate

        # 生成正交输出
        sin_out = np.sin(self.phase)
        cos_out = np.cos(self.phase)

        # 更新相位（模2π）
        self.phase += self.phase_increment
        self.phase %= 2 * np.pi

        return sin_out, cos_out


class Mixer:
    """正交混频器"""

    @staticmethod
    def mix(signal, sin, cos):
        """正交下变频"""
        I = signal * cos
        Q = signal * sin
        return I, Q


class LoopFilter:
    """环路滤波器(PI控制器)"""

    def __init__(self, loop_bandwidth, sample_rate):
        self.alpha = 2 * loop_bandwidth / sample_rate  # 比例系数
        self.beta = (loop_bandwidth / sample_rate) ** 2  # 积分系数
        self.integrator = 0.0

    def update(self, phase_error):
        """更新滤波器状态并返回频率控制字"""
        # 比例项
        prop = self.alpha * phase_error

        # 积分项
        self.integrator += self.beta * phase_error

        # 总频率控制
        freq_ctrl = prop + self.integrator

        return freq_ctrl


class FIRFilter:
    """低通FIR滤波器"""

    def __init__(self, cutoff, sample_rate, numtaps=64):
        self.numtaps = numtaps
        self.cutoff = cutoff
        self.sample_rate = sample_rate
        self.taps = signal.firwin(numtaps, cutoff, fs=sample_rate)
        self.z_i = signal.lfilter_zi(self.taps, 1.0)
        self.z_q = signal.lfilter_zi(self.taps, 1.0)

    def filter(self, I, Q):
        """滤波I/Q两路信号"""
        I_filtered, self.z_i = signal.lfilter(self.taps, 1.0, [I], zi=self.z_i)
        Q_filtered, self.z_q = signal.lfilter(self.taps, 1.0, [Q], zi=self.z_q)
        return I_filtered[0], Q_filtered[0]


class CostasLoop:
    """完整的Costas环实现"""

    def __init__(self, sample_rate, carrier_freq, loop_bandwidth):
        self.sample_rate = sample_rate
        self.nco = NCO(sample_rate, carrier_freq)
        self.mixer = Mixer()
        self.loop_filter = LoopFilter(loop_bandwidth, sample_rate)
        self.lpf = FIRFilter(carrier_freq / 2, sample_rate)  # 截止频率设为载波的一半

        # 状态变量
        self.I = 0.0
        self.Q = 0.0
        self.I_filtered = 0.0
        self.Q_filtered = 0.0
        self.phase_error = 0.0
        self.freq_ctrl = carrier_freq

    def update(self, sample):
        """处理一个输入样本"""
        # 1. NCO生成正交信号
        sin, cos = self.nco.update(self.freq_ctrl)

        # 2. 正交下变频
        self.I, self.Q = self.mixer.mix(sample, sin, cos)

        # 3. 低通滤波
        self.I_filtered, self.Q_filtered = self.lpf.filter(self.I, self.Q)

        # 4. 相位检测(BPSK)
        self.phase_error = self.I_filtered * self.Q_filtered

        # 5. 环路滤波
        self.freq_ctrl = self.loop_filter.update(self.phase_error)

        # 返回解调后的I路信号(即解调数据)
        return self.I_filtered


def generate_bpsk(symbol_rate, carrier_freq, sample_rate, duration, freq_offset=0):
    """生成BPSK测试信号"""
    t = np.arange(0, duration, 1 / sample_rate)
    num_samples = len(t)

    # 生成随机符号
    num_symbols = int(duration * symbol_rate)
    symbols = np.random.choice([-1, 1], num_symbols)

    # 升采样
    samples_per_symbol = int(sample_rate / symbol_rate)
    bpsk_signal = np.repeat(symbols, samples_per_symbol)
    bpsk_signal = bpsk_signal[:num_samples]  # 修剪

    # 添加载波和频率偏移
    carrier = np.exp(1j * (2 * np.pi * (carrier_freq + freq_offset) * t))
    modulated = bpsk_signal * np.real(carrier)

    # 添加噪声
    snr_db = 20
    noise_power = 10 ** (-snr_db / 10)
    noise = np.sqrt(noise_power) * np.random.randn(num_samples)
    modulated += noise

    return t, modulated


def main():
    # 参数设置
    sample_rate = 32e6  # 32 MHz采样率
    symbol_rate = 100e3  # 100 kbps符号率
    carrier_freq = 2e6  # 200 kHz载波
    freq_offset = 5e3  # 5 kHz频率偏移(测试捕获能力)
    duration = 0.01  # 10 ms持续时间
    loop_bw = 10e3  # 10 kHz环路带宽

    # 生成测试信号
    t, bpsk_signal = generate_bpsk(symbol_rate, carrier_freq, sample_rate, duration, freq_offset)

    # 初始化Costas环
    costas = CostasLoop(sample_rate, carrier_freq, loop_bw)

    # 处理信号
    demodulated = np.zeros_like(bpsk_signal)
    freq_track = np.zeros_like(bpsk_signal)

    for i in range(len(bpsk_signal)):
        demodulated[i] = costas.update(bpsk_signal[i])
        freq_track[i] = costas.freq_ctrl

    # 绘图
    plt.figure(figsize=(12, 8))

    plt.subplot(3, 1, 1)
    plt.title("Original BPSK Signal")
    plt.plot(t, bpsk_signal)
    plt.grid(True)

    plt.subplot(3, 1, 2)
    plt.title("Demodulated Signal")
    plt.plot(t, demodulated)
    plt.grid(True)

    plt.subplot(3, 1, 3)
    plt.title("Frequency Tracking")
    plt.plot(t, freq_track, label='Estimated Frequency')
    plt.axhline(y=carrier_freq + freq_offset, color='r', linestyle='--', label='Actual Frequency')
    plt.legend()
    plt.grid(True)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()