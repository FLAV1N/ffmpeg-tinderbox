#!/bin/bash

OGG_REPO="https://github.com/xiph/ogg.git"
OGG_COMMIT="0288fadac3ac62d453409dfc83e9c4ab617d2472"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$OGG_REPO" "$OGG_COMMIT" ogg
    cd ogg

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DINSTALL_DOCS=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}
