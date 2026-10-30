#!/bin/sh
# Runs build.sh in the toolchain image. TOOLCHAIN_IMAGE overrides the image.
set -eu
export MSYS_NO_PATHCONV=1
image=${TOOLCHAIN_IMAGE:-ghcr.io/defkorns/classicmini-cross-toolchain:v1.2.0}
docker run --rm -v "$PWD:/w" -w /w "$image" sh build.sh
