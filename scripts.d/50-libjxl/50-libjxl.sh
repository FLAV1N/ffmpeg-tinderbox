#!/bin/bash

JXL_REPO="https://github.com/libjxl/libjxl.git"
JXL_COMMIT="7d047b5feca7a4a0bd620de171179d2c3810bc8e"

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

    echo "Libs.private: -lstdc++" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl.pc
    echo "Libs.private: -lstdc++" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl_threads.pc
    echo "Libs.private: -ladvapi32" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl.pc
    echo "Libs.private: -ladvapi32" >> "${FFBUILD_PREFIX}"/lib/pkgconfig/libjxl_threads.pc
}

ffbuild_configure() {
    echo --enable-libjxl
}

ffbuild_unconfigure() {
    [[ $ADDINS_STR == *5.0* ]] && return 0
    echo --disable-libjxl
}
