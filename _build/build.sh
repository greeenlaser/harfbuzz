#!/bin/sh

# Move file for use with mf, read more at https://github.com/greeenlaser/personal-stash/tree/main/mf

set -e

#
# References
#

KMAKE_ORIGIN=project.kmake

SRC_ORIGIN=../src
SRC_TARGET=.

case "$1" in
    --linux)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-linux"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-linux"

        TARGET_REL_DIR=release-linux
        TARGET_DEB_DIR=debug-linux
        ;;
    --windows-gnu)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows-gnu"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows-gnu"

        TARGET_REL_DIR=release-windows-gnu
        TARGET_DEB_DIR=debug-windows-gnu
        ;;
    --windows)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows"

        TARGET_REL_DIR=release-windows
        TARGET_DEB_DIR=debug-windows
        ;;
    *)
        echo "Error: Argument must be --linux, --windows-gnu or --windows" >&2
        exit 1
        ;;
esac

#
# Copy dependencies
#

if [ -d "include" ]; then
    rm -rf "include"
fi

mf --o --f "${SRC_ORIGIN}" --t "${SRC_TARGET}"

#
# Compile
#

kalamake ${BUILD_RELEASE} || exit 1
kalamake ${BUILD_DEBUG} || exit 1

#
# Cleanup
#

mv "src" "include"

# Delete all files that arent .h or .hh
find "include" -type f ! \( -name '*.h' -o -name '*.hh' \) -delete

# Delete empty directories recursively
find "include" -type d -empty -delete

if [ -d "${TARGET_REL_DIR}/obj" ]; then
    rm -rf "${TARGET_REL_DIR}/obj"
fi

if [ -d "${TARGET_DEB_DIR}/obj" ]; then
    rm -rf "${TARGET_DEB_DIR}/obj"
fi

mf --o --f "include" --t "${TARGET_REL_DIR}"
mf --o --f "include" --t "${TARGET_DEB_DIR}"

mf --o --f "../COPYING" --t "${TARGET_REL_DIR}/LICENSE"
mf --o --f "../COPYING" --t "${TARGET_DEB_DIR}/LICENSE"

rm -rf "include"
