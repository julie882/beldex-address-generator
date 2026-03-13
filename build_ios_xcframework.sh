#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_BUILD_DIR="${ROOT_DIR}/build-ios-sim"
DEVICE_BUILD_DIR="${ROOT_DIR}/build-ios-device"
OUTPUT_DIR="${ROOT_DIR}/sample_app/ios/WalletFFI.xcframework"

: "${IOS_BOOST_SIM_ROOT:?Set IOS_BOOST_SIM_ROOT to the Boost prefix built for iphonesimulator.}"
: "${IOS_BOOST_DEVICE_ROOT:?Set IOS_BOOST_DEVICE_ROOT to the Boost prefix built for iphoneos.}"

configure_and_build() {
  local build_dir="$1"
  local sysroot="$2"
  local archs="$3"
  local boost_root="$4"

  cmake -S "${ROOT_DIR}" -B "${build_dir}" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DCMAKE_BUILD_TYPE=Release \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBOOST_ROOT="${boost_root}" \
    -DBoost_ROOT="${boost_root}"

  cmake --build "${build_dir}" --config Release --target wallet
}

find_static_lib() {
  local build_dir="$1"
  find "${build_dir}" -name libwallet.a -print -quit
}

configure_and_build "${SIM_BUILD_DIR}" iphonesimulator "arm64;x86_64" "${IOS_BOOST_SIM_ROOT}"
configure_and_build "${DEVICE_BUILD_DIR}" iphoneos "arm64" "${IOS_BOOST_DEVICE_ROOT}"

SIM_LIB="$(find_static_lib "${SIM_BUILD_DIR}")"
DEVICE_LIB="$(find_static_lib "${DEVICE_BUILD_DIR}")"

if [[ -z "${SIM_LIB}" || -z "${DEVICE_LIB}" ]]; then
  echo "Failed to locate libwallet.a in one of the iOS build directories." >&2
  exit 1
fi

rm -rf "${OUTPUT_DIR}"

xcodebuild -create-xcframework \
  -library "${SIM_LIB}" -headers "${ROOT_DIR}/wallet" \
  -library "${DEVICE_LIB}" -headers "${ROOT_DIR}/wallet" \
  -output "${OUTPUT_DIR}"

echo "Created ${OUTPUT_DIR}"
