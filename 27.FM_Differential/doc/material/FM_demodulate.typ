#import "conf.typ": *

#let title = "FM Demodulator"
#let subtitle = "some information about FM demodulation"
#let authors = (
  (
    name: "Visier Rational",
    affiliation: "Lumen Institute",
    email: "visier@lument.org",
  ),
  (
    name: "Visier Emotional",
    affiliation: "Lumen Institute",
    email: "visier@lument.org",
  ),
  (
    name: "Visier Philosophical",
    affiliation: "Lumen Institute",
    email: "visier@lument.org",
  ),
)
#let abstract = "这篇资料主要介绍了FM解调器的基本原理与设计实现。采用FPGA实现，主要包括NCO、混频器和FIR滤波器等模块。注意，此种解调方式只能针对特定条件下的FM信号进行解调，且不包含FM调制讲解。"
#let claim = "My soul does not yearn for immortality, but to exhaust the realm of all possibilities."
#let term-table = ()

#show: doc => conf(
  title: title,
  subtitle: subtitle,
  authors: authors,
  abstract: abstract,
  claim: claim,
  date: datetime(year: 2025, month: 7, day: 8),
  lang: "en",
  terms: term-table,
  doc,
)

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center } else { left }
  ),
)



= Introduction
本文档用于解释附属工程FM Demodulator的设计与实现。采用FPGA实现，主要包括NCO、混频器和FIR滤波器等模块。
= Theory Supports
本工程采用同向正交法（I/Q）进行FM解调。I/Q信号的生成和处理是通过NCO（数控振荡器）和混频器实现的。解调过程使用了FIR滤波器来提取所需的信号成分。

== FM Modulation signal derivation

FM 调制信号：

$ X_"RF" (t) = A cos(2 pi f_c t + phi(t)) $

正交分量形式:
$ X_"FM" (t) = I(t) cos(2 pi f_c t) - Q(t) sin(2 pi f_c t) $
欧拉公式形式:
$ X_"FM" (t) = A e^(j(2 pi f_c t + phi(t))) $
解析信号：
$ X_"analytic" (t) = X_"RF" (t) + j H[X_"RF" (t)] $
其中 $H[X_"RF" (t)]$ 是 $X_"RF" (t)$ 的希尔伯特变换。
乘以 $e^(-j 2 pi f_c t)$ 得到基带信号：
$ X_"base" (t) = X_"analytic" (t) e^(-j 2 pi f_c t) $
意义：频谱搬移，载波归0
基带信号欧拉公式展开:
$ X_"base" (t) = A e^(j phi(t)) = I(t) + j Q(t) $

== FM Demodulation
解调过程的核心是从基带信号中提取出相位信息 $phi(t)$。通过对基带信号进行希尔伯特变换，可以得到正交分量 $I(t)$ 和 $Q(t)$。解调后的信号可以表示为：
$ phi(t) = arg(X_"base" (t)) = arctan(Q(t) / I(t)) $
数字实现中，通常使用差分方法来近似计算相位变化：
$
  s(t) & prop d/d_t arctan(Q(t) / I(t))  \
       & approx I[n-1] Q[n] - Q[n-1]I[n]
$


#warning("此种解调方式只能针对特定条件下的FM信号进行解调")
= 条件说明
== 最优解调条件
#figure(
  image("./Img/Base1kFIR100k.png"),
  caption: "基带信号频率为1kHz，FIR截止频率为100kHz的解调结果",
)
== 滤波器影响
滤波器的设计对解调结果有显著影响。过宽的带宽可能导致噪声干扰，而过窄的带宽则可能导致信号失真。
#figure(
  image("./Img/FIR10k.png"),
  caption: "FIR截止频率为10kHz的滤波器响应",
)
#figure(
  image("./Img/FIR1000k.png"),
  caption: "FIR截止频率为1000kHz的滤波器响应",
)
== 基带信号频率影响
基带信号的频率也会影响解调结果。较低频率的基带信号可能导致解调器无法正确跟踪相位变化，而较高频率的基带信号则可能导致过采样和计算负担。
#figure(
  image("./Img/Base100.png"),
  caption: "基带信号频率为100Hz的响应",
)
#figure(
  image("./Img/Base10k.png"),
  caption: "基带信号频率为10kHz的响应",
)
)
