# FM Demodulator / FM 解调器

[English](#english-version) | [中文](#中文版本)

---

## English Version

This project implements a basic **FM demodulator** using FPGA hardware modules. The design includes key components such as:

- **Numerically Controlled Oscillator (NCO)**
- **Quadrature Mixer**
- **FIR Low-Pass Filter**

The demodulator uses **I/Q demodulation** with Hilbert transform principles, making it suitable for constrained FM signals (e.g., known carrier and deviation).  
Sampling frequency is set to **100 MHz**, with performance tested under varying carrier and baseband conditions.

> ⚠️ **Note**: This demodulation method only works under specific assumptions and **does not** include FM modulation.

### Features

- ✅ Narrowband FM demodulation  
- ✅ FPGA hardware implementation (Verilog/SystemVerilog)  
- ✅ Test cases and signal analysis included  

### How to Use

1. Load the project onto your FPGA board (e.g., Intel/Altera/Quartus) or run the `bench`.
2. Feed FM-modulated input signal to the ADC interface.
3. View demodulated output from DAC or logic analyzer.

### Documentation

See: [`/doc/FM_Demodulator.pdf`](./doc/FM_Demodulator.pdf)

---

## 中文版本

本项目使用 FPGA 实现了一个基本的 **调频（FM）解调器**，主要包含以下模块：

- **数控振荡器（NCO）**
- **正交混频器**
- **FIR 低通滤波器**

该解调器基于 **Hilbert 变换的 I/Q 解调原理**，适用于频偏和载波已知的窄带 FM 信号。  
采样频率设为 **100 MHz**，并在不同的载波和基带条件下进行了实验验证。

> ⚠️ **注意**：此解调方法仅适用于特定条件，不包含 FM 调制部分。

### 特性

- ✅ 支持窄带 FM 解调  
- ✅ FPGA 硬件实现（Verilog/SystemVerilog）  
- ✅ 提供测试样例和信号分析  

### 使用方法

1. 将工程烧录到 FPGA 板卡（如 Intel/Altera/Quartus）或者运行`仿真`。
2. 将调频（FM）信号输入至 ADC 接口。
3. 通过 DAC 或逻辑分析仪查看解调结果。

### 文档参考

参见：[`/doc/FM_Demodulator.pdf`](./doc/FM_Demodulator.pdf)
