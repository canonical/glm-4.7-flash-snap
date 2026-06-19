#!/bin/bash -eu
set -o pipefail

MODEL_DIR="$(dirname "$0")/components/model-glm4-7-flash-q4-k-m"
MODEL_URL="https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF/resolve/main/GLM-4.7-Flash-Q4_K_M.gguf"
MODEL_FILE="$MODEL_DIR/GLM-4.7-Flash-Q4_K_M.gguf"
N_SHARDS=4

mkdir -p "$MODEL_DIR"

if [ ! -f "$MODEL_FILE" ]; then
    echo "Downloading GLM-4.7-Flash-Q4_K_M.gguf..."
    wget -c -O "$MODEL_FILE" "$MODEL_URL"
else
    echo "Model file already exists, skipping download."
fi

SPLITTER=""
if command -v llama-gguf-split &> /dev/null; then
    SPLITTER="llama-gguf-split"
elif [ -x "/tmp/llama.cpp/build/bin/llama-gguf-split" ]; then
    SPLITTER="/tmp/llama.cpp/build/bin/llama-gguf-split"
fi

if [ -n "$SPLITTER" ]; then
    echo "Splitting model into $N_SHARDS shards..."
    cd "$MODEL_DIR"
    $SPLITTER --split --split-max-size 5.3G "$MODEL_FILE" "$MODEL_FILE"
    # Rename shards from .gguf-N-of-M.gguf to N-of-M.gguf
    for f in GLM-4.7-Flash-Q4_K_M.gguf-*-of-00004.gguf; do
        suffix=$(echo "$f" | grep -oP '\d{5}-of-\d{5}')
        mv -v "$f" "GLM-4.7-Flash-Q4_K_M-$suffix.gguf"
    done
    echo "Shards created:"
    ls -la GLM-4.7-Flash-Q4_K_M-*.gguf
    echo "Removing original single file..."
    rm -f "$MODEL_FILE"
else
    echo "ERROR: llama-gguf-split not found. Cannot shard the model."
    echo "Install it from: https://github.com/ggerganov/llama.cpp"
    exit 1
fi
