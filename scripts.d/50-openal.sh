#!/bin/bash

OPENAL_REPO="https://github.com/kcat/openal-soft.git"
OPENAL_COMMIT="05c94a670d0b357260598741b52497e34e6e17aa"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OPENAL_REPO" "$OPENAL_COMMIT" openal
    cd openal

    mkdir cmbuild && cd cmbuild

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DLIBTYPE=STATIC \
        -DALSOFT_{EXAMPLES,UTILS,INSTALL_{AMBDEC_PRESETS,CONFIG,EXAMPLES,HRTF_DATA,UTILS}}=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private.*/& -lstdc++ -lole32 -luuid/' "$FFBUILD_PREFIX"/lib/pkgconfig/openal.pc
}

ffbuild_configure() {
    echo --enable-openal
}

ffbuild_unconfigure() {
    echo --disable-openal
}
