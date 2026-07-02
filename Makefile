SHELL := /bin/bash

.PHONY: all download-models setup-hf-cli download-model split-model setup-gguf-split clean-shards clean

MODEL_FILE := GLM-4.7-Flash-Q4_K_M.gguf
MODEL_URL := https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF/resolve/main/$(MODEL_FILE)
COMPONENT_DIR := components
MODEL_SLUG := glm47flash-q4km
N_SHARDS := 4

# Maximum size per shard passed to gguf-split. 4800M keeps each of the 4 shards
# well under the 5 GB per-component Store limit (18.3 GB / 4 ~= 4.58 GB).
SPLIT_MAX_SIZE := 4800M

# llama.cpp build that ships llama-gguf-split. Keep in sync with snap/snapcraft.yaml.
LLAMACPP_TAG := b9611
LLAMACPP_ARCH := $(shell dpkg --print-architecture)
LLAMACPP_URL := https://github.com/canonical/llama.cpp-builds/releases/download/$(LLAMACPP_TAG)/llamacpp-$(LLAMACPP_ARCH).tar.gz
GGUF_SPLIT := .tools/llamacpp/bin/llama-gguf-split

all: download-models split-model

setup-hf-cli:
	sudo apt-get install -y python3-venv
	python3 -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -U huggingface_hub

download-model:
	mkdir -p $(COMPONENT_DIR)/model-$(MODEL_SLUG)
	. .venv/bin/activate && hf download unsloth/GLM-4.7-Flash-GGUF $(MODEL_FILE) --local-dir $(COMPONENT_DIR)/model-$(MODEL_SLUG)

download-models: setup-hf-cli download-model

# Fetch the llama.cpp build so we can use llama-gguf-split on the build host.
setup-gguf-split:
	@if [ ! -x "$(GGUF_SPLIT)" ]; then \
	  echo "Fetching llama.cpp ($(LLAMACPP_TAG), $(LLAMACPP_ARCH)) for gguf-split..."; \
	  sudo apt-get install -y libgomp1; \
	  mkdir -p .tools/llamacpp; \
	  curl -fSL "$(LLAMACPP_URL)" -o .tools/llamacpp.tar.gz; \
	  tar -xzf .tools/llamacpp.tar.gz -C .tools/llamacpp; \
	  rm -f .tools/llamacpp.tar.gz; \
	fi

# Split the single GGUF into N valid multi-part GGUF shards using llama-gguf-split.
# Each shard (GLM-4.7-Flash-Q4_K_M-00001-of-000NN.gguf ...) is a loadable GGUF;
# llama-server is pointed at shard 1 and auto-discovers the rest from the same dir.
# Each shard lands in its own component directory model-$(MODEL_SLUG)-<i>-of-$(N_SHARDS).
split-model: setup-gguf-split clean-shards
	mkdir -p $(COMPONENT_DIR)/.tmp
	LD_LIBRARY_PATH="$(CURDIR)/.tools/llamacpp/lib:$$LD_LIBRARY_PATH" \
	  "$(CURDIR)/$(GGUF_SPLIT)" --split --split-max-size $(SPLIT_MAX_SIZE) \
	  "$(COMPONENT_DIR)/model-$(MODEL_SLUG)/$(MODEL_FILE)" \
	  "$(COMPONENT_DIR)/.tmp/GLM-4.7-Flash-Q4_K_M"
	@count=$$(ls $(COMPONENT_DIR)/.tmp/*.gguf | wc -l); \
	if [ "$$count" -ne "$(N_SHARDS)" ]; then \
	  echo "ERROR: expected $(N_SHARDS) shards but gguf-split produced $$count."; \
	  echo "Adjust SPLIT_MAX_SIZE so the shard count matches N_SHARDS."; \
	  ls -lh $(COMPONENT_DIR)/.tmp/*.gguf; \
	  rm -rf $(COMPONENT_DIR)/.tmp; \
	  exit 1; \
	fi
	@i=1; \
	for shard in $(COMPONENT_DIR)/.tmp/*.gguf; do \
	  dir="$(COMPONENT_DIR)/model-$(MODEL_SLUG)-$$i-of-$(N_SHARDS)"; \
	  mkdir -p "$$dir"; \
	  mv "$$shard" "$$dir/"; \
	  echo "  -> $$dir/$$(basename "$$shard")"; \
	  i=$$((i + 1)); \
	done
	rm -rf $(COMPONENT_DIR)/.tmp

clean-shards:
	rm -rf $(COMPONENT_DIR)/model-$(MODEL_SLUG)-*

clean:
	rm -rf $(COMPONENT_DIR)/model-$(MODEL_SLUG)-*
	rm -f *.snap *.comp
	rm -rf parts/ prime/ stage/
	rm -rf .venv/
	rm -rf .tools/
