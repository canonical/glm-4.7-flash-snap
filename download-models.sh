#!/bin/bash -ex

# CI entrypoint invoked by build-publish-snap.yaml (init-build-script).
# Downloads the GLM-4.7-Flash Q4_K_M GGUF and splits it into <5 GB shards so
# each shard can be packed as a separate component (Store 5 GB/component limit).
make download-models
make split-model
