#!/bin/bash

LIBUDFREAD_REPO="https://github.com/nanake/libudfread.git"
LIBUDFREAD_COMMIT="b3e6936a23f8af30a0be63d88f4695bdc0ea26e1"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBUDFREAD_REPO" "$LIBUDFREAD_COMMIT" libudfread
    cd libudfread

    ./bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
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

    ln -s libudfread.pc "$FFBUILD_PREFIX"/lib/pkgconfig/udfread.pc
}
