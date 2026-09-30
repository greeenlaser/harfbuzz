#!/bin/sh

# Move file for use with mf, read more at https://github.com/greeenlaser/personal-stash/tree/main/mf

set -e

#
# References
#

KMAKE_ORIGIN=project.kmake

LICENSE_ORIGIN=../COPYING
LICENSE_TARGET=COPYING

SRC_ORIGIN=../src
SRC_TARGET=.

case "$1" in
    --linux)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-linux"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-linux"
        ;;
    --windows-gnu)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows-gnu"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows-gnu"
        ;;
    --windows)
        BUILD_RELEASE="--compile ${KMAKE_ORIGIN} release-windows"
        BUILD_DEBUG="--compile ${KMAKE_ORIGIN} debug-windows"
        ;;
    *)
        echo "Error: Argument must be --linux, --windows-gnu or --windows" >&2
        exit 1
        ;;
esac

#
# Copy sources, headers and license
#

mf --o --f "${LICENSE_ORIGIN}" --t "${LICENSE_TARGET}"
mv "${LICENSE_TARGET}" "LICENSE"

# Sources and headers

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

# Rename harfbuzz src dir to include dir

mv "src" "include"

# Delete all files that arent .h or .hh
find "include" -type f ! \( -name '*.h' -o -name '*.hh' \) -delete

# Delete empty directories recursively
find "include" -type d -empty -delete

rm -rf "release/obj"
rm -rf "debug/obj"
