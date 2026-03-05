# Beldex - offline - wallet - generation

## Requirements

- CMake ≥ 3.16
- GNU Make
- MinGW (for Windows cross-compile)
- Android NDK r26+
- GCC / Clang

## Clone project

```
git clone https://github.com/victor-tucci/address-generator-c-.git
cd address-generator-c
```

# Linux 

## Boost Installation:
 

```
wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz
tar -xf boost_1_83_0.tar.gz
cd boost_1_83_0
./bootstrap.sh
./b2 --clean-all
./b2 install \
  --prefix=/usr/local \
  --with-system \
  --with-thread \
  --with-filesystem \
  --with-program_options \
  --with-serialization \
  --with-atomic \
  --with-date_time
 ```

Installed Location:
/usr/local/include/boost
/usr/local/lib

## Project build:
```
mkdir build
cd build
cmake ..
make -j$(nproc)
```



# Windows (MinGW Cross-Compile)


## Boost Installation:

```
wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz
tar -xf boost_1_83_0.tar.gz
./bootstrap.sh
./b2 --clean-all
```

- Edit-file: `nano user-config.jam`
Add
 `using gcc : mingw : x86_64-w64-mingw32-g++ ;`

- Build Boost for Windows:
```
./b2 \
  toolset=gcc-mingw \
  target-os=windows \
  address-model=64 \
  threading=multi \
  threadapi=win32 \
  variant=release \
  link=static \
  runtime-link=static \
  --prefix=/opt/boost-mingw \
  --with-system \
  --with-thread \
  --with-serialization \
  --with-program_options \
  install
  ```

- Installed Location:
/opt/boost-mingw/include
/opt/boost-mingw/lib

## Project build:

```
chmod +x build_windows.sh
./build_windows.sh
```

Output:

build-windows/wallet/libwallet.dll



# Android

## Install procedure for android :
`android-ndk-r26b-linux.zip`

Supported ABIs: arm64-v8a, armeabi-v7a, x86_64

```
wget https://boostorg.jfrog.io/artifactory/main/release/1.83.0/source/boost_1_83_0.tar.gz)
tar -xf boost_1_83_0.tar.gz
./bootstrap.sh
./b2 --clean-all
```

- Edit-file: `nano user-config.jam`
Add:
```
#using clang : android
  : /path/to/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang++
  : <cxxflags>"--target=armv7-none-linux-androideabi21 -fPIC"
    <linkflags>"--target=armv7-none-linux-androideabi21"
  ;
#arm64-v8a (64-bit ARM)
using clang : android64
  : /path/to/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++
  : <cxxflags>"--target=aarch64-none-linux-android21 -fPIC"
    <linkflags>"--target=aarch64-none-linux-android21"
  ;
x86_64
#using clang : android_x86_64
  : /path/to/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang++
  : <cxxflags>"--target=x86_64-none-linux-android21 -fPIC"
    <linkflags>"--target=x86_64-none-linux-android21"
  ;
  ```

- Build Boost for  Android:
armeabi-v7a
```
./b2 toolset=clang-android \
  target-os=android \
  architecture=arm \
  address-model=32 \
  threading=multi \
  --prefix=./stage/armeabi-v7a \
  --with-system --with-thread --with-atomic \
  --with-serialization --with-program_options --with-date_time \
  install
  ```

arm64-v8a
```
./b2 toolset=clang-android64 \
  target-os=android \
  architecture=arm \
  address-model=64 \
  threading=multi \
  --prefix=./stage/arm64-v8a \
  --with-system --with-thread --with-atomic \
  --with-serialization --with-program_options --with-date_time \
  install
  ```

x86_64
```
./b2 toolset=clang-android_x86_64 \
  target-os=android \
  architecture=x86 \
  address-model=64 \
  threading=multi \
  --prefix=./stage/x86_64 \
  --with-system --with-thread --with-atomic \
  --with-serialization --with-program_options --with-date_time \
  install
  ```

## Project build:
```
chmod +x build_all_android.sh
./build_all_android.sh
```

Output:

build-android/
  arm64-v8a/libwallet.so
  armeabi-v7a/libwallet.so
  x86_64/libwallet.so



