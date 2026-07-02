# GLM 4.7 Flash inference snap

Available engines:
* nvidia-gpu
* cpu

#### Install
```
sudo snap install glm-4-7-flash
```
#### Use
```
glm-4-7-flash --help
```


#### Default ports
| Configuration |              |
|---------------|--------------|
| http server   | 4894         |
| webui server  | 4895         |
| http host     | 127.0.0.1    |

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone this repo with its submodules:
```shell
git clone --recurse-submodules https://github.com/canonical/glm-4.7-flash-snap
```

Download the model and split it into shards (the Q4_K_M GGUF is ~18 GB and must
be split so each component stays under the 5 GB Store limit):
```shell
make download-models
make split-model
```

Build the snap and its components:
```shell
snapcraft pack -v
```

Refer to the `./dev` directory for additional development tools.
