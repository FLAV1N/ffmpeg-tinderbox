#!/bin/bash

OPENAPV_REPO="https://github.com/AcademySoftwareFoundation/openapv.git"
OPENAPV_COMMIT="f1f43a6ff5905e8b2a36ac956022ecd801597466"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=main --single-branch "$OPENAPV_REPO" openapv
    cd openapv
    git checkout "$OPENAPV_COMMIT"

    echo > app/CMakeLists.txt

    mkdir build && cd build

    # 💥 symbol collision with libxeve
    export CFLAGS="$CFLAGS -Dthreadsafe_assign=oapv_threadsafe_assign"

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_TESTS=OFF \
        -DOAPV_APP_STATIC_BUILD=ON \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install

    mv "$FFBUILD_PREFIX"/lib{/oapv/liboapv.a,}
    rm -rf "$FFBUILD_PREFIX"/{lib/oapv,include/oapv/oapv_exports.h}

    {
        echo "Libs.private: -lm"
        echo "Cflags.private: -DOAPV_STATIC_DEFINE"
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/oapv.pc
}

ffbuild_configure() {
    echo --enable-liboapv
}

ffbuild_unconfigure() {
    echo --disable-liboapv
}
