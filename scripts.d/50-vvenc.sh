#!/bin/bash

VVENC_REPO="https://github.com/fraunhoferhhi/vvenc.git"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VVENC_REPO" "$VVENC_COMMIT" vvenc
    cd vvenc

    mkdir build && cd build

    if [[ $TARGET == *arm64 ]]; then
    fixarm64=(
        -DVVENC_ENABLE_X86_SIMD=OFF
    )
    fi
    
    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DVVENC_ENABLE_LINK_TIME_OPT=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DVVENC_OPT_TARGET_ARCH=znver3 \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -GNinja \
        $fixarm64 \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    echo --disable-libvvenc
}