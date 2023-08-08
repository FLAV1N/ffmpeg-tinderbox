#!/bin/bash

MINGW_STD_THREADS_REPO="https://github.com/meganz/mingw-std-threads.git"
MINGW_STD_THREADS_COMMIT="c931bac289dd431f1dd30fc4a5d1a7be36668073"

ffbuild_enabled() {
    [[ $TARGET == win* ]] || return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_STD_THREADS_REPO" "$MINGW_STD_THREADS_COMMIT" mingw-std-threads
    cd mingw-std-threads

    mkdir -p "$FFBUILD_PREFIX"/include
    cp *.h "$FFBUILD_PREFIX"/include
}
