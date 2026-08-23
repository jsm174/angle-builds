#!/bin/bash

set -e

cd "$(dirname "$0")/../.."

source ./platforms/config.sh

echo "Staging ANGLE (macos-arm64)..."
echo "  ANGLE_SHA: ${ANGLE_SHA}"
echo ""

WORK="external/macos-arm64"
DIST="dist/macos-arm64"

mkdir -p "${WORK}" "${DIST}"

#
# fetch depot_tools
#

if [ ! -d "${WORK}/depot_tools" ]; then
   git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git "${WORK}/depot_tools"
fi

export PATH="$(pwd)/${WORK}/depot_tools:${PATH}"

#
# fetch ANGLE source (pinned by commit SHA)
#

ANGLE_SRC="${WORK}/angle"
ANGLE_FOUND_SHA="$([ -f ${ANGLE_SRC}/cache.txt ] && cat ${ANGLE_SRC}/cache.txt || echo "")"

if [ "${ANGLE_SHA}" != "${ANGLE_FOUND_SHA}" ]; then
   echo "Fetching ANGLE source. Expected: ${ANGLE_SHA}, Found: ${ANGLE_FOUND_SHA}"

   rm -rf "${ANGLE_SRC}"
   git init -q "${ANGLE_SRC}"
   git -C "${ANGLE_SRC}" remote add origin https://chromium.googlesource.com/angle/angle
   git -C "${ANGLE_SRC}" fetch --depth 1 origin "${ANGLE_SHA}"
   git -C "${ANGLE_SRC}" checkout -q FETCH_HEAD

   echo "${ANGLE_SHA}" > "${ANGLE_SRC}/cache.txt"
fi

#
# sync dependencies and build
#

cd "${ANGLE_SRC}"
python3 scripts/bootstrap.py
gclient sync -D --no-history

mkdir -p out/Release
printf 'is_debug = false\n' > out/Release/args.gn
gn gen out/Release
autoninja -C out/Release libEGL libGLESv2
cd - >/dev/null

cp "${ANGLE_SRC}/out/Release/libEGL.dylib" "${DIST}/"
cp "${ANGLE_SRC}/out/Release/libGLESv2.dylib" "${DIST}/"
cp "${ANGLE_SRC}/LICENSE" "${DIST}/ANGLE-LICENSE.txt"

echo "staged ${DIST}"
