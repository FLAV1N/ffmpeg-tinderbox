#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="98bdd77b296da207ab42c3113ec8f30de58db197"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    # Kill build of unused and broken tools
    echo > libvmaf/tools/meson.build

    mkdir build && cd build

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        -Ddefault_library=static
        -D{built_in_models,enable_float}"=true"
        -Denable_{docs,tests}"=false"
    )

    if [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson setup "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private.*/& -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
