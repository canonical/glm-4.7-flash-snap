SHELL := /bin/bash

# Always run `hf` via pipx to avoid relying on local `hf` installations.
hf := pipx run --spec "huggingface_hub[cli]" hf

SNAP_NAME ?= glm-4-7-flash
ENGINE ?= cpu

MODEL_REPO := inference-snaps/GLM-4.7-Flash-30B-A3B-Q4_K_M-5GB
MODEL_BASENAME := GLM-4.7-Flash-Q4_K_M
COMPONENT_DIR := components
MODEL_SLUG := q4-k-m-gguf
N_SHARDS := 4

.PHONY: all help init build install upload smoke-test install-deps init-submodules download-models

all: help

#
# Main targets
#

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@# List all targets with descriptions (lines starting with '##'):
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-11s %s\n", $$1, $$2}'

init: init-submodules install-deps download-models ## Initialize the build environment (dependencies, model weights, submodules, etc.)

build: ## Build the snap
	./dev/build.sh

install: ## Install the snap
	./dev/install.sh

upload: ## Upload the snap
	./dev/upload.sh

smoke-test: ## Run smoke tests (override with SNAP_NAME=... ENGINE=...)
	sudo ./dev/smoke-test.sh $(SNAP_NAME) $(ENGINE)

#
# Supporting targets
#

install-deps:
	@echo "Installing dependencies..."
	@# Ensure pipx is available for running the hf CLI.
	@command -v pipx >/dev/null 2>&1 || { \
		sudo apt-get update; \
		sudo apt-get install -y pipx; \
	}

init-submodules:
	@echo "Initializing submodules..."
	@if git submodule status | grep -q '^-'; then \
		git submodule update --init; \
	fi

# Download the pre-sharded GGUF files directly into their per-component shard directories.
download-models:
	@echo "Downloading GLM-4.7-Flash-Q4_K_M model weights..."
	@total=$$(printf "%05d" "$(N_SHARDS)"); \
	for i in $$(seq 1 $(N_SHARDS)); do \
		shard_num=$$(printf "%05d" "$$i"); \
		shard_file="$(MODEL_BASENAME)-$${shard_num}-of-$${total}.gguf"; \
		dir="$(COMPONENT_DIR)/model-$(MODEL_SLUG)-$$i-of-$(N_SHARDS)"; \
		mkdir -p "$$dir"; \
		echo "Downloading $$shard_file -> $$dir"; \
		$(hf) download "$(MODEL_REPO)" "$$shard_file" --local-dir "$$dir"; \
	done
