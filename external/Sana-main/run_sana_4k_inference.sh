#!/usr/bin/env bash
# SANA 4K 推理脚本：直接运行即可，需要改参数时编辑下面变量后执行 ./run_sana_4k_inference.sh
# 需先下载（离线推理建议全部放到 checkpoints/）：
#   1) 4K 主模型：Sana_1600M_4Kpx_BF16（见 model_zoo）
#   2) VAE（DC-AE）：huggingface-cli download mit-han-lab/dc-ae-f32c32-sana-1.1-diffusers --local-dir checkpoints/dc-ae-f32c32-sana-1.1-diffusers
#   3) 文本编码器（gemma-2-2b-it）：huggingface-cli download Efficient-Large-Model/gemma-2-2b-it --local-dir checkpoints/gemma-2-2b-it
#       然后设置下面 TEXT_ENCODER_PATH，否则会连 HF 在线拉取
#
# 单步推理：把下面两行改成 SAMPLING_ALGO="flow_euler" 且 STEP=1 即可（画质会明显下降，因未做单步蒸馏）

set -e
cd "$(dirname "$0")"

# ========== 可修改参数 ==========
CONFIG="configs/sana_config/4096ms/Sana_1600M_img4096_bf16.yaml"
# 4K 权重路径（可从 HF 下载 Efficient-Large-Model/Sana_1600M_4Kpx_BF16 后放到此处）
MODEL_PATH="${PWD}/checkpoints/Sana_1600M_4Kpx_BF16/checkpoints/Sana_1600M_4Kpx_BF16.pth"
# VAE（DC-AE）本地路径。不设则从 HF 在线加载（需能访问 huggingface.co）
# 下载：huggingface-cli download mit-han-lab/dc-ae-f32c32-sana-1.1-diffusers --local-dir checkpoints/dc-ae-f32c32-sana-1.1-diffusers
# VAE：可填仓库根目录或 snapshots/<commit> 目录
VAE_PATH="${PWD}/checkpoints/dc-ae-f32c32-sana-1.1-diffusers"
# 文本编码器（gemma-2-2b-it）本地路径，不设则从 HF 在线加载
TEXT_ENCODER_PATH="${PWD}/checkpoints/gemma-2-2b-it"

TXT_FILE="asset/samples/samples_1000.txt"
WORK_DIR="./output"
SAMPLE_NUMS=1000
# 4K 显存/内存占用大，建议先跑 1 张；batch 保持 1
CFG_SCALE=4.5
# 采样器：flow_dpm-solver（默认，最少 2 步）或 flow_euler（可 1 步）
SAMPLING_ALGO="flow_dpm-solver"
# 推理步数：-1 表示用采样器默认（flow_dpm-solver=20，flow_euler=28）
# 单步推理：设为 1，且 SAMPLING_ALGO 改为 flow_euler（flow_dpm-solver 最少 2 步）
# 注意：标准 SANA 4K 未做单步蒸馏，步数越少画质越差
STEP=-1
# ================================

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate sana

# 若已设置本地路径且目录存在，则覆盖 config，避免连 HF
EXTRA_ARGS=()
if [ -n "$VAE_PATH" ] && [ -d "$VAE_PATH" ]; then
  EXTRA_ARGS+=(--vae.vae_pretrained "$VAE_PATH")
fi
if [ -n "$TEXT_ENCODER_PATH" ] && [ -d "$TEXT_ENCODER_PATH" ]; then
  EXTRA_ARGS+=(--text_encoder.text_encoder_name "$TEXT_ENCODER_PATH")
fi

python scripts/inference.py \
  --config="$CONFIG" \
  --model_path="$MODEL_PATH" \
  --txt_file="$TXT_FILE" \
  --work_dir="$WORK_DIR" \
  --sample_nums="$SAMPLE_NUMS" \
  --cfg_scale="$CFG_SCALE" \
  --sampling_algo="$SAMPLING_ALGO" \
  --step="$STEP" \
  "${EXTRA_ARGS[@]}"
