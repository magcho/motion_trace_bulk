#!/usr/bin/env bash
echo ---
echo "---  映像データから各種トレースデータを揃えてvmdを生成する"
echo ---

echo -----------------------------------
echo "各種ソースコードへのディレクトリパス(相対 or 絶対)"
echo -----------------------------------
echo --- Openpose
OPENPOSE_DIR="../openpose-1.4.0-win64-gpu-binaries"
echo --- "OpenposeDemo.exeのあるディレクトリパス(PortableDemo版: bin, 自前ビルド版: Release)"
OPENPOSE_BIN_DIR="bin"
echo --- 3d-pose-baseline-vmd
BASELINE_DIR="../3d-pose-baseline-vmd"
echo -- 3dpose_gan_vmd
GAN_DIR="../3dpose_gan_vmd"
echo -- FCRN-DepthPrediction-vmd
DEPTH_DIR="../FCRN-DepthPrediction-vmd"
echo -- VMD-3d-pose-baseline-multi
VMD_DIR="../VMD-3d-pose-baseline-multi"

echo -- Openpose 実行
# sh BulkOpenpose_Docker.sh
