AOM_REPO="https://github.com/Clybius/aom-av1-lavish"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=opmox/mainline-merge --single-branch "$AOM_REPO" aom
    cd aom

    mkdir aom_build && cd aom_build

    cmake -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
    -DCMAKE_CXX_FLAGS="-O3 -march=znver3" \
    -DCMAKE_C_FLAGS="-O3 -march=znver3" \
    -DCMAKE_C_FLAGS_INIT="-static -static-libgcc -static-libstdc++" \
    -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++" \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_EXAMPLES=NO \
    -DENABLE_TESTS=NO \
    -DCONFIG_AV1_DECODER=1 \
    -DENABLE_TOOLS=NO \
    -DCONFIG_TUNE_VMAF=0 \
    -DCONFIG_TUNE_BUTTERAUGLI=0 \
    -GNinja \
    ..
    ninja -j$(nproc)
    ninja install
}

ffbuild_configure() {
    echo --enable-libaom
}

ffbuild_unconfigure() {
    echo --disable-libaom
}