#!/bin/bash

JXL_REPO="https://github.com/libjxl/libjxl.git"
JXL_COMMIT="ef97fe07656e385bbd1af3801635b66bdbd413f2"

ffbuild_enabled() {
    [[ $ADDINS_STR == *5.0* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$JXL_REPO" "$JXL_COMMIT" jxl
    cd jxl
    git submodule update --init --recursive --depth 1 --recommend-shallow third_party/{highway,skcms}

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_{SHARED_LIBS,TESTING}=OFF \
        -DJPEGXL_{BUNDLE_LIBPNG,EMSCRIPTEN,STATIC}=OFF \
        -DJPEGXL_ENABLE_{BENCHMARK,DEVTOOLS,DOXYGEN,EXAMPLES,JNI,MANPAGES,PLUGINS,SJPEG,TOOLS,VIEWERS}=OFF \
        -DJPEGXL_FORCE_SYSTEM_BROTLI=ON \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    echo "Cflags.private: -DJXL_STATIC_DEFINE=1" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl.pc
    echo "Libs.private: -lstdc++" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl.pc

    echo "Cflags.private: -DJXL_STATIC_DEFINE=1" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl_threads.pc
    echo "Libs.private: -lstdc++" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl_threads.pc
    echo "Libs.private: -ladvapi32" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl.pc
    echo "Libs.private: -ladvapi32" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl_threads.pc

    mv "${FFBUILD_PREFIX}"/lib/libjxl{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libjxl_dec{-static,}.a
    mv "${FFBUILD_PREFIX}"/lib/libjxl_threads{-static,}.a
}

ffbuild_configure() {
    echo --enable-libjxl
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *5.0* ]] && return 0
    echo --disable-libjxl
}