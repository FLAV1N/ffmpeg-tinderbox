#!/bin/bash

SVTAV1_REPO="https://github.com/gianni-rosato/svt-av1-psy"
SVTAV1_COMMIT="testing"

ffbuild_enabled() {
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SVTAV1_REPO" "$SVTAV1_COMMIT" svtav1
    cd svtav1

    mkdir build && cd build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_{DEC,SHARED_LIBS,TESTING,APPS}=OFF \
        -DSVT_AV1_LTO=ON \
        -DCMAKE_CXX_FLAGS="-Ofast" \
        -DCMAKE_C_FLAGS="-Ofast" \
        -DCMAKE_LD_FLAGS="-Ofast" \
        -DCMAKE_CXX_FLAGS="-march=znver3" \
        -DCMAKE_C_FLAGS="-march=znver3" \
        -DCMAKE_LD_FLAGS="-march=znver3" \
        -DENABLE_AVX512=ON \
        -DENABLE_NASM=ON \
        -CC="/usr/bin/clang" \
        -CXX="/usr/bin/clang++" \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libsvtav1
}
ffbuild_unconfigure() {
    echo --disable-libsvtav1
}