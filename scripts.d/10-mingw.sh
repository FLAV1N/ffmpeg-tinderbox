#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="b38a7d3e8016d920f02aad09187e4a5f6ae46246"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /"
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw

    cd mingw-w64-headers

    unset CFLAGS
    unset CXXFLAGS
    unset LDFLAGS
    unset PKG_CONFIG_LIBDIR

    local myconf=(
        --prefix="/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"

    cd ../mingw-w64-libraries/winpthreads

    local myconf=(
        --prefix="/usr/$FFBUILD_TOOLCHAIN"
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
