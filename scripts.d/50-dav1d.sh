#!/bin/bash

DAV1D_REPO="https://github.com/videolan/dav1d.git"
DAV1D_COMMIT="6c6d25d355b78556d231b1a5633ded2ddb9e3774"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "COPY $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$DAV1D_REPO" "$DAV1D_COMMIT" dav1d
    cd dav1d

    mkdir build && cd build

    export CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" .. || return -1
    ninja -j$(nproc) || return -1
    ninja install || return -1

    cd ../..
    rm -rf dav1d
}

ffbuild_configure() {
    echo --enable-libdav1d
}

ffbuild_unconfigure() {
    echo --disable-libdav1d
}
