#!/usr/bin/env bash
# Sana-Sprint 推理脚本：直接运行即可，需要改参数时编辑下面变量后执行 ./run_sprint_inference.sh

set -e
cd "$(dirname "$0")"

# ========== 可修改参数 ==========
CONFIG="configs/sana_sprint_config/1024ms/SanaSprint_600M_1024px_allqknorm_bf16_scm_ladd.yaml"
MODEL_PATH="${PWD}/checkpoints/Sana_Sprint_0.6B_1024px/checkpoints/Sana_Sprint_0.6B_1024px.pth"
TXT_FILE="asset/samples/samples_mini.txt"
WORK_DIR="./output"
SAMPLE_NUMS=5
# ================================

# 激活 conda 环境（若已激活可注释掉下面两行）
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate sana

python scripts/inference_sana_sprint.py \
  --config="$CONFIG" \
  --model_path="$MODEL_PATH" \
  --txt_file="$TXT_FILE" \
  --work_dir="$WORK_DIR" \
  --sample_nums="$SAMPLE_NUMS"
