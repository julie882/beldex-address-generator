#!/bin/bash

PROJECT_DIR=$(pwd)
BUILD_DIR=$PROJECT_DIR/build-windows

echo "Cleaning old build..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

echo "Configuring for Windows (MinGW)..."

cmake $PROJECT_DIR \
  -DCMAKE_SYSTEM_NAME=Windows \
  -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc \
  -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++ \
  -DBOOST_ROOT=/opt/boost-mingw \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_BUILD_TYPE=Release

echo "Building..."
make -j$(nproc)

echo "Windows build completed."