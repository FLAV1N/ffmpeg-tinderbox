#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="833753684d3a520ebcd3cd73e614c97bbb55ffb8"

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

    unset CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_LIBDIR

    SYSROOT="$($CC -print-sysroot)"

    local myconf=(
        --prefix="$SYSROOT/mingw"
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    if [[ $TARGET != win64 ]]; then
        myconf+=(
            --with-default-msvcrt=msvcrt
        )
    fi

    ./configure "${myconf[@]}"
    make -j"$(nproc)"
    make install DESTDIR="/opt/mingw"
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
