📱⚡ Edge4K-Raw2RGB

面向移动端的 4K 单步 RAW-to-RGB 生成系统
结合 MobileDiffusion / SANA / SANA-Sprint 的加速思想

⸻

🎯 项目目标

本项目旨在探索：

在移动端实现 4K 分辨率、单步（1-step）RAW→RGB 推理，并将端到端延迟压缩至 5 秒以内。

核心目标：
	•	✅ 单步推理（1-step）
	•	✅ 原生 4K 支持（优先），兼容 Tiling
	•	✅ 端侧友好结构（NPU / INT8）
	•	✅ 延迟 < 5s（长期目标）
	•	✅ 模块级 profiling + 可量化优化路径

⸻

🧠 技术路线概述

本项目将融合以下三条技术路线：

🔹 MobileDiffusion 思路
	•	多步蒸馏 → 单步
	•	轻量化 UNet 结构
	•	解码器专门加速
	•	端侧整体 profiling 拆解

🔹 SANA 思路
	•	高压缩率 AutoEncoder（如 32×）
	•	Linear DiT（线性注意力）
	•	Mix-FFN + 3×3 DWConv 局部增强
	•	面向高分辨率可扩展设计

🔹 SANA-Sprint 思路
	•	连续时间一致性蒸馏
	•	对抗蒸馏增强单步锐度
	•	单步质量保持优化

⸻

🏗️ 项目结构

diffusion/
│
├── external/                 # 上游开源仓库（git submodule）
│   ├── SANA/
│   ├── SANA-Sprint/
│
├── configs/
│   ├── baseline/
│   ├── experiments/
│
├── models/
│   ├── autoencoder/
│   ├── backbone/
│   ├── decoder/
│
├── raw_pipeline/
│   ├── demosaic/
│   ├── burst/
│   ├── alignment/
│
├── tiling/
│   ├── tile_utils.py
│   ├── blending.py
│
├── profiling/
│   ├── latency_breakdown.py
│   ├── memory_profile.py
│
├── deploy/
│   ├── npu/
│   ├── quantization/
│
└── README.md


⸻

🔬 第一阶段：Baseline 复现

1️⃣ 复现 SANA（1K & 4K）

目标：
	•	复现 1024×1024 推理（先跑通最小可用链路）
	•	测试原生 4K 推理（重点测 token/latents 扩展规律）
	•	分析 latent 压缩倍率对 token 数与显存/耗时的影响
	•	测量 4K 下 AE 编码/解码成本（判断瓶颈是否在 decoder）

⸻

2️⃣ 复现 SANA-Sprint（单步）

目标：
	•	复现 1-step / 少步推理（与 SANA 共享 AE/主干时优先复用）
	•	对比蒸馏策略对「单步质量 vs 速度」的影响（以推理为主，不纠结训练细节）
	•	形成 1K 单步端到端 profiling 模板（后续 raw→rgb 直接复用）

⸻

3️⃣ MobileDiffusion（论文复刻 / 关键 trick 萃取）

说明：
	•	MobileDiffusion 论文中训练数据为“proprietary dataset（1.5 亿图文对）”，并未提供官方开源训练仓库与可复现权重，因此本项目不以“完整复现 MobileDiffusion”为硬性里程碑。
	•	我们把它当作端侧优化的 trick 清单来源：UNet 架构瘦身、注意力拆分（高分辨率去 SA 留 CA）、separable conv、激活函数替换（gelu→swish）、softmax→relu attention 微调、decoder 轻量化等。

落地目标：
	•	在可获取的开源基线（SANA / Sprint / SD 生态）上，逐项实现并验证上述 trick 的收益（以 profiling 数据为准）。

⸻

🧪 实验路线图

阶段 1：性能拆解
	•	1K 单步延迟拆解
	•	4K 单步延迟拆解
	•	Decoder 占比分析
	•	Token 数与主干耗时关系分析
	•	原生 4K vs Tiling 对比

⸻

阶段 2：结构优化

Latent 压缩优化
	•	AE 压缩倍率测试（/16 → /32）
	•	细节损失 vs 性能提升对比

Backbone 优化
	•	Linear Attention 替换
	•	Mix-FFN 局部增强
	•	INT8 / INT4 量化

Decoder 优化
	•	轻量化解码器设计
	•	Tile Decode + Overlap Blending
	•	将后处理迁移至 latent 域

⸻

阶段 3：端侧部署优化
	•	全算子 NPU 适配
	•	固定 shape，消除动态分配
	•	Kernel 融合
	•	内存复用与 buffer 预分配
	•	功耗与热降频监控

⸻

📊 Profiling 标准模板

每次实验必须记录：

分辨率:
是否 Tiling:
Tile size:
Overlap:
Latent 压缩倍率:

延迟拆解:
- RAW 预处理:
- Global 分支:
- Encoder:
- Backbone:
- Decoder:
- 后处理:
- 总延迟:

峰值内存:
功耗:


⸻

🔥 关键研究问题
	1.	RAW→RGB 任务可接受的最大 latent 压缩倍率是多少？
	2.	Linear Attention 是否会影响 ISP 精度？
	3.	4K 下是否 Decoder 才是真正瓶颈？
	4.	原生 4K 是否优于 Tiled 4K？
	5.	是否可以在移动端实现 4K 单步 <5s？

⸻

📌 当前进度

模块	状态
MobileDiffusion trick 复刻（paper）	⬜
SANA 1K baseline	⬜
SANA 4K baseline	⬜
Sprint 单步 baseline	⬜
4K Tiling	⬜
NPU 部署	⬜


⸻

🧭 长期目标

构建一个：
	•	单步 4K RAW→RGB 模型
	•	移动端可运行
	•	端到端 <5 秒
	•	色彩准确、可复现
	•	支持 Tiling 无接缝

⸻
