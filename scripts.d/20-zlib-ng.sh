#!/bin/bash

ZLIB_REPO="https://github.com/zlib-ng/zlib-ng.git"
ZLIB_COMMIT="57a2ed9e503bfeb92577c87aa49b9b0727d97120"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$ZLIB_REPO" "$ZLIB_COMMIT" zlib
    cd zlib

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DZLIB_COMPAT=ON \
        -DZLIB{,NG}_ENABLE_TESTS=OFF \
        -DWITH_GTEST=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-zlib
}

ffbuild_unconfigure() {
    echo --disable-zlib
}