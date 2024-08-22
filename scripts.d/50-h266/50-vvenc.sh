#!/bin/bash

VVENC_REPO="https://github.com/fraunhoferhhi/vvenc.git"
VVENC_COMMIT="efb49f49592a3d102f4cc027c7fd71326a55362a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VVENC_REPO" "$VVENC_COMMIT" vvenc
    cd vvenc

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DVVENC_ENABLE_LINK_TIME_OPT=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    sed -i 's|/[^ ]*libstdc++.a|stdc++|' "$FFBUILD_PREFIX"/lib/pkgconfig/libvvenc.pc
}

ffbuild_configure() {
    echo --enable-libvvenc
}

ffbuild_unconfigure() {
    echo --disable-libvvenc
}
