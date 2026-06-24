#!/bin/bash

VULKAN_REPO="https://github.com/BtbN/Vulkan-Shim-Loader.git"
VULKAN_COMMIT="65b3936528cd92eb4ea3de485d03f858a3850484"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VULKAN_REPO" "$VULKAN_COMMIT" vulkan
    cd vulkan

    # Update Vulkan-Headers to the latest commit
    git submodule update --init --remote

    cd Vulkan-Headers
    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_HEADERS_ENABLE_INSTALL=YES \
        -DVULKAN_HEADERS_ENABLE_{MODULE,TESTS}=NO \
        -GNinja \
        ..
    ninja install

    cd ../..
    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DVULKAN_SHIM_IMPERSONATE=ON \
        -GNinja \
        ..
    ninja "-j$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
