#!/bin/bash

DAVS2_REPO="https://github.com/pkuvcl/davs2.git"
DAVS2_COMMIT="master"

ffbuild_enabled() {
    [[ $VARIANT == lgpl* ]] && return -1
    [[ $TARGET == win32 ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git clone --filter=tree:0 --branch=master --single-branch "$DAVS2_REPO" davs2
    cd davs2
    git checkout "$DAVS2_COMMIT"
    cd build/linux

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-{cli,win32thread}
        --enable-pic
    )

    if [[ $TARGET == win64 ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
            --cross-prefix="$FFBUILD_CROSS_PREFIX"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install
}

ffbuild_configure() {
    echo --enable-libdavs2
}

ffbuild_unconfigure() {
    echo --disable-libdavs2
}
