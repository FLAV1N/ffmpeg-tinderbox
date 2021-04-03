#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="e23732666b24792fee70afbb830b2f1805db30d6"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "COPY $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    mkdir build && cd build

    export CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Denable_tests=false
        -Denable_docs=false
        -Denable_avx512=true
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private.*/& -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc

    cd ../..
    rm -rf vmaf
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
