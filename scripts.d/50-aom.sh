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
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_LINKER=lld \
    -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
    -DCMAKE_CXX_FLAGS="-fuse-ld=lld -O3 -march=znver3 -flto=thin -pipe" \
    -DCMAKE_C_FLAGS="-fuse-ld=lld -O3 -march=znver3 -flto=thin -pipe" \
    -DCMAKE_EXE_LINKER_FLAGS="-flto -static" \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_EXAMPLES=NO \
    -DENABLE_TESTS=NO \
    -DCONFIG_AV1_DECODER=0 \
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