#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIM_BUILD_DIR="${ROOT_DIR}/build-ios-sim"
DEVICE_BUILD_DIR="${ROOT_DIR}/build-ios-device"
OUTPUT_DIR="${ROOT_DIR}/sample_app/ios/WalletFFI.xcframework"
IOS_PROJECT_DIR="${ROOT_DIR}/sample_app/ios"
DEFAULT_SIM_BOOST_ROOT="${ROOT_DIR}/build-boost-ios/iphonesimulator"
DEFAULT_DEVICE_BOOST_ROOT="${ROOT_DIR}/build-boost-ios/iphoneos"

IOS_BOOST_SIM_ROOT="${IOS_BOOST_SIM_ROOT:-${DEFAULT_SIM_BOOST_ROOT}}"
IOS_BOOST_DEVICE_ROOT="${IOS_BOOST_DEVICE_ROOT:-${DEFAULT_DEVICE_BOOST_ROOT}}"
DEFAULT_GENERATOR="Ninja"

if ! command -v ninja >/dev/null 2>&1; then
  DEFAULT_GENERATOR="Unix Makefiles"
fi

if [[ ! -d "${IOS_BOOST_SIM_ROOT}" ]]; then
  echo "iOS simulator Boost prefix not found at ${IOS_BOOST_SIM_ROOT}" >&2
  echo "Build it first with ./build_boost_ios.sh or set IOS_BOOST_SIM_ROOT." >&2
  exit 1
fi

if [[ ! -d "${IOS_BOOST_DEVICE_ROOT}" ]]; then
  echo "iOS device Boost prefix not found at ${IOS_BOOST_DEVICE_ROOT}" >&2
  echo "Build it first with ./build_boost_ios.sh or set IOS_BOOST_DEVICE_ROOT." >&2
  exit 1
fi

configure_and_build() {
  local build_dir="$1"
  local sysroot="$2"
  local archs="$3"
  local boost_root="$4"
  local c_compiler
  local cxx_compiler

  c_compiler="$(xcrun --sdk "${sysroot}" -f clang)"
  cxx_compiler="$(xcrun --sdk "${sysroot}" -f clang++)"

  rm -rf "${build_dir}"

  cmake -S "${ROOT_DIR}" -B "${build_dir}" -G "${DEFAULT_GENERATOR}" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_C_COMPILER="${c_compiler}" \
    -DCMAKE_CXX_COMPILER="${cxx_compiler}" \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
    -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
    -DCMAKE_BUILD_TYPE=Release \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBOOST_ROOT="${boost_root}"
  cmake --build "${build_dir}" --config Release --target wallet
}

merge_static_libs() {
  local build_dir="$1"
  local boost_dir="$2"
  local merged_lib="${build_dir}/libwallet.a"
  
  local project_libs
  project_libs=$(find "${build_dir}" -name "*.a" ! -path "*/libwallet.a")
  project_libs="${project_libs} ${build_dir}/wallet/libwallet.a"
  
  local boost_libs=""
  for lib in system thread serialization atomic date_time; do
    if [[ -f "${boost_dir}/lib/libboost_${lib}.a" ]]; then
      boost_libs="${boost_libs} ${boost_dir}/lib/libboost_${lib}.a"
    fi
  done
  
  libtool -static -o "${merged_lib}" ${project_libs} ${boost_libs}
  echo "${merged_lib}"
}

configure_and_build "${SIM_BUILD_DIR}" iphonesimulator "arm64;x86_64" "${IOS_BOOST_SIM_ROOT}"
configure_and_build "${DEVICE_BUILD_DIR}" iphoneos "arm64" "${IOS_BOOST_DEVICE_ROOT}"

SIM_LIB="$(merge_static_libs "${SIM_BUILD_DIR}" "${IOS_BOOST_SIM_ROOT}")"
DEVICE_LIB="$(merge_static_libs "${DEVICE_BUILD_DIR}" "${IOS_BOOST_DEVICE_ROOT}")"

if [[ ! -f "${SIM_LIB}" || ! -f "${DEVICE_LIB}" ]]; then
  echo "Failed to create merged libwallet in one of the iOS build directories." >&2
  exit 1
fi

rm -rf "${OUTPUT_DIR}"

xcodebuild -create-xcframework \
  -library "${SIM_LIB}" -headers "${ROOT_DIR}/wallet" \
  -library "${DEVICE_LIB}" -headers "${ROOT_DIR}/wallet" \
  -output "${OUTPUT_DIR}"

echo "Created ${OUTPUT_DIR}"

if command -v pod >/dev/null 2>&1 && [[ -f "${IOS_PROJECT_DIR}/Podfile" ]]; then
  (
    cd "${IOS_PROJECT_DIR}"
    pod install
  )
  echo "Updated CocoaPods workspace for WalletFFI."
else
  echo "Skipping pod install. Run 'cd sample_app/ios && pod install' after creating the xcframework."
fi
