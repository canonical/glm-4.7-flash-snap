#!/bin/bash -ex

# CI entrypoint invoked by build-publish-snap.yaml (init-build-script).
# Downloads the GLM-4.7-Flash Q4_K_M GGUF shards
make all
