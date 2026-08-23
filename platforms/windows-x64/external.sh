#!/bin/bash

set -e

cd "$(dirname "$0")/../.."

source ./platforms/config.sh

echo "Staging ANGLE (windows-x64)..."
echo "  ANGLE_SHA: ${ANGLE_SHA}"
echo ""

WORK="external/windows-x64"
DIST="dist/windows-x64"

mkdir -p "${WORK}" "${DIST}"

export DEPOT_TOOLS_WIN_TOOLCHAIN=0

PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

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
# sync dependencies and build against the newest complete Windows SDK
#

SDK_ROOT="/c/Program Files (x86)/Windows Kits/10/Include"
SDK_VERSION=""
for version in $(ls "${SDK_ROOT}" | sort); do
   if [ -f "${SDK_ROOT}/${version}/um/windows.h" ]; then
      SDK_VERSION="${version}"
   fi
done
if [ -z "${SDK_VERSION}" ]; then
   echo "No complete Windows SDK found in ${SDK_ROOT}" >&2
   exit 1
fi
echo "Using Windows SDK ${SDK_VERSION}"

cd "${ANGLE_SRC}"
"${PY}" scripts/bootstrap.py
gclient sync -D --no-history

mkdir -p out/Release
printf 'is_debug = false\nwindows_sdk_version = "%s"\n' "${SDK_VERSION}" > out/Release/args.gn
gn gen out/Release
autoninja -C out/Release libEGL libGLESv2
cd - >/dev/null

cp "${ANGLE_SRC}/out/Release/libEGL.dll" "${DIST}/"
cp "${ANGLE_SRC}/out/Release/libGLESv2.dll" "${DIST}/"
if [ -f "${ANGLE_SRC}/out/Release/d3dcompiler_47.dll" ]; then
   cp "${ANGLE_SRC}/out/Release/d3dcompiler_47.dll" "${DIST}/"
fi
cp "${ANGLE_SRC}/LICENSE" "${DIST}/ANGLE-LICENSE.txt"

echo "staged ${DIST}"
