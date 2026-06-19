# Inference Snap for GLM-4.7 Flash

This repository contains the snap packaging for [GLM-4.7 Flash](https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF), an LLM optimized for fast inference.

## Getting Started

```bash
git clone --recurse-submodules https://github.com/canonical/glm4.7-flash
cd glm4.7-snap
```

### Download Model Weights

```bash
./download-models.sh
```

### Build the Snap

```bash
snapcraft pack --destructive-mode
```

### Install

```bash
sudo snap install glm4-7_*.snap --dangerous
sudo snap install glm4-7_*.comp --dangerous
```

### Connect Interfaces

```bash
sudo snap connect glm4-7:hardware-observe
sudo snap connect glm4-7:opengl
sudo snap connect glm4-7:network-bind
sudo snap connect glm4-7:process-control
```

## Ports

| Service | Port |
|---------|------|
| API     | 8348 |
| WebUI   | 8349 |
