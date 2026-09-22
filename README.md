# GLM 4.7 Flash inference snap
[![glm-4-7-flash](https://snapcraft.io/glm-4-7-flash/badge.svg)](https://snapcraft.io/glm-4-7-flash)

GLM-4.7-Flash is Zhipu AI's 30B-A3B mixture-of-experts instruction-tuned model with reasoning and tool-calling capabilities.

Use this snap to quickly install an optimized environment for local inference with GLM 4.7 Flash.

The snap includes the following hardware-optimized inference engines:

* cpu: Optimized for x64 and ARM (armv8, armv9) CPUs
* nvidia-gpu: CUDA-enabled GPU acceleration

The most suitable engine is automatically selected based on the available hardware.

#### Install
```shell
sudo snap install glm-4-7-flash
```

#### Run
```shell
glm-4-7-flash
```

> [!TIP]
> Some accelerators require extra [drivers](https://documentation.ubuntu.com/inference-snaps/how-to/setup/drivers/) to be usable with this snap.

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone the repo:
```shell
git clone https://github.com/canonical/glm-4.7-flash-snap
cd glm-4.7-flash-snap
```

Initialize the development environment:
```shell
make init
```

Build and install snap:
```shell
make build
make install
```
