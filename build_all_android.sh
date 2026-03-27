#!/bin/bash

NDK=/root/Android/Sdk/ndk/25.2.9519653/android-ndk-r25c
PROJECT_DIR=$(pwd)
OUTPUT_DIR=$PROJECT_DIR/build-android

ABIS=("armeabi-v7a" "arm64-v8a" "x86_64")

mkdir -p $OUTPUT_DIR

for ABI in "${ABIS[@]}"
do
    echo "==============================="
    echo "Building for ABI: $ABI"
    echo "==============================="

    BUILD_DIR=$OUTPUT_DIR/$ABI
    rm -rf $BUILD_DIR
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR

    cmake $PROJECT_DIR \
        -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$ABI \
        -DANDROID_PLATFORM=android-21 \
        -DCMAKE_BUILD_TYPE=Release

    make -j$(nproc)

    cd $PROJECT_DIR
done

echo "All Android builds completed."