SHELL := /bin/bash

.PHONY: all download-models setup-hf-cli download-shards clean-shards clean

MODEL_REPO := inference-snaps/GLM-4.7-Flash-30B-A3B-Q4_K_M-5GB
MODEL_BASENAME := GLM-4.7-Flash-Q4_K_M
COMPONENT_DIR := components
MODEL_SLUG := q4-k-m-gguf
N_SHARDS := 4

all: download-models

setup-hf-cli:
	sudo apt-get install -y python3-venv
	python3 -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -U huggingface_hub

download-models: setup-hf-cli download-shards

# Download pre-sharded GGUF files directly into per-component shard directories.
download-shards: clean-shards
	@total=$$(printf "%05d" "$(N_SHARDS)"); \
	for i in $$(seq 1 $(N_SHARDS)); do \
	  shard_num=$$(printf "%05d" "$$i"); \
	  shard_file="$(MODEL_BASENAME)-$${shard_num}-of-$${total}.gguf"; \
	  dir="$(COMPONENT_DIR)/model-$(MODEL_SLUG)-$$i-of-$(N_SHARDS)"; \
	  mkdir -p "$$dir"; \
	  echo "Downloading $$shard_file -> $$dir"; \
	  . .venv/bin/activate && hf download "$(MODEL_REPO)" "$$shard_file" --local-dir "$$dir"; \
	done

clean-shards:
	rm -rf $(COMPONENT_DIR)/model-$(MODEL_SLUG)-*

clean:
	rm -rf $(COMPONENT_DIR)/model-$(MODEL_SLUG)-*
	rm -f *.snap *.comp
	rm -rf parts/ prime/ stage/
	rm -rf .venv/
