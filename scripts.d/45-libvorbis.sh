#!/bin/bash

VORBIS_REPO="https://github.com/xiph/vorbis.git"
VORBIS_COMMIT="84c023699cdf023a32fa4ded32019f194afcdad0"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VORBIS_REPO" "$VORBIS_COMMIT" vorbis
    cd vorbis

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --disable-oggtest
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libvorbis
}

ffbuild_unconfigure() {
    echo --disable-libvorbis
}
