# Costas Loop Demodulator / Costas 环解调器

[English](#english-version) | [中文](#中文版本)

---

## English

This project focuses on the **analysis and FPGA implementation of the Costas Loop** for **carrier recovery and phase synchronization** in digital communication systems. Specifically, it details its application in BPSK/QPSK demodulation.

The Costas Loop is a powerful **Phase-Locked Loop (PLL) structure** that automatically corrects carrier phase errors during demodulation by establishing a feedback system. Key modules and their functions are thoroughly analyzed:

-   **Numerically Controlled Oscillator (NCO)**: Generates local carrier signals.
-   **Quadrature Mixer**: Mixes input signals with NCO outputs to produce I/Q components.
-   **Low-Pass Filter (FIR)**: Extracts baseband signals by filtering out high-frequency components.
-   **Error Calculation Unit**: Computes the phase error signal $e[n] = I[n] \cdot Q[n]$.
-   **Loop Filter**: A Proportional-Integral (PI) controller that processes the error signal to adjust the NCO's frequency and phase.

The document includes a detailed derivation of the BPSK Costas Loop structure and explains the digital error estimation and adjustment mechanisms.

> ⚠️ **Note**: The Costas Loop is designed for carrier recovery in suppressed-carrier modulation systems (like BPSK/QPSK) where the carrier is unknown but symbols are known. It is not directly applicable to frequency modulation (FM) signals.

### Features

-   ✅ **Carrier Synchronization**: Robustly recovers the carrier phase and frequency.
-   ✅ **BPSK/QPSK Demodulation**: Suitable for coherent demodulation of BPSK and QPSK signals.
-   ✅ **FPGA Implementation**: Designed for hardware implementation using Verilog/SystemVerilog, focusing on digital signal processing blocks.
-   ✅ **Modularity**: Clearly defined modules (NCO, Mixer, LPF, Loop Filter, Error Unit) for ease of understanding and reuse.

### How to Use

1.  Integrate the provided Verilog/SystemVerilog modules into your FPGA design environment (e.g., Vivado, Quartus).
2.  Connect the sampled RF signal to the **ADC Interface**.
3.  The demodulated I/Q components can be accessed for further processing (e.g., symbol decision).
4.  Adjust loop filter constants ($k_p, k_i$) to optimize lock speed and jitter.

### Documentation

See: [`/doc/Costas_Loop_Demodulator.pdf`](./doc/Costas_Loop_Demodulator.pdf)

---

## 中文

本项目详细介绍了 **Costas 环（Costas Loop）** 在数字通信系统中进行 **载波恢复与相位同步** 的基本原理与 FPGA 实现方法。特别侧重于其在 BPSK/QPSK 解调中的应用。

Costas 环是一种强大的 **锁相环（PLL）结构**，通过构建一个反馈系统，在解调过程中自动校正载波的相位误差。文中详细分析了其关键模块及其功能：

-   **数控振荡器（NCO）**：生成本地载波信号。
-   **正交混频器**：将输入信号与 NCO 输出的同相（I）和正交（Q）信号相乘。
-   **低通滤波器（FIR）**：滤除混频结果中的高频分量，提取基带信号。
-   **误差计算单元**：计算相位误差信号 $e[n] = I[n] \cdot Q[n]$。
-   **环路滤波器**：通常为比例-积分（PI）控制器，处理误差信号以调整 NCO 的频率和相位。

文档中包含了 BPSK Costas 环结构的详细推导，并解释了数字误差估计与调节机制。

> ⚠️ **注意**：Costas 环适用于载波未知、符号已知的同步系统，如抑制载波调制（BPSK/QPSK）。它不能直接用于频率调制（FM）信号的解调。

### 特性

-   ✅ **载波同步**：鲁棒地恢复载波的相位和频率。
-   ✅ **BPSK/QPSK 解调**：适用于 BPSK 和 QPSK 信号的相干解调。
-   ✅ **FPGA 实现**：专为使用 Verilog/SystemVerilog 进行硬件实现而设计，专注于数字信号处理模块。
-   ✅ **模块化**：模块结构清晰（NCO、混频器、低通滤波器、环路滤波器、误差计算单元），易于理解和复用。

### 使用方法

1.  将提供的 Verilog/SystemVerilog 模块集成到您的 FPGA 设计环境中（例如 Vivado, Quartus）。
2.  将采样后的射频信号连接到 **ADC 接口**。
3.  解调后的 I/Q 分量可供后续处理（例如符号判决）。
4.  调节环路滤波器常数（$k_p, k_i$）以优化锁定速度和抖动。

### 文档参考

参见：[`/doc/Costas_Loop_Demodulator.pdf`](./doc/Costas_Loop_Demodulator.pdf)