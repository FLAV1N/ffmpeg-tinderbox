#!/bin/bash

FFNVCODEC_REPO="https://github.com/FFmpeg/nv-codec-headers.git"
FFNVCODEC_COMMIT="22441b505d9d9afc1e3002290820909846c24bdc"
FFNVCODEC_BRANCH2="sdk/12.0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$FFNVCODEC_REPO" "$FFNVCODEC_COMMIT" ffnvcodec
    cd ffnvcodec

    make PREFIX="$FFBUILD_PREFIX" install
}

ffbuild_configure() {
    echo --enable-ffnvcodec --enable-cuda-llvm
}

ffbuild_unconfigure() {
    echo --disable-ffnvcodec --disable-cuda-llvm
}

ffbuild_cflags() {
    return 0
}

ffbuild_ldflags() {
    return 0
}
