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
wget https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.gz
tar -xzf boost_1_83_0.tar.gz
cd boost_1_83_0
./bootstrap.sh
./b2 --clean-all
./b2 toolset=gcc \
--prefix=/usr/local \
link=static runtime-link=static threading=multi variant=release \
--with-system --with-thread --with-filesystem \
--with-program_options --with-serialization --with-atomic --with-date_time \
install
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
wget https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.gz
tar -xzf boost_1_83_0.tar.gz
cd boost_1_83_0
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

`android-ndk-r25c-linux.zip`
```
mkdir -p ~/Android/Sdk/ndk
cd ~/Android/Sdk/ndk
wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
unzip android-ndk-r25c-linux.zip
mv android-ndk-r25c 25.2.9519653
export ANDROID_NDK=~/Android/Sdk/ndk/25.2.9519653
```

## Build All required boost modules

```
mkdir boost_1_83_0
cd boost_1_83_0
./b2 --clean-all
./bootstrap.sh

```

Supported ABIs: arm64-v8a, armeabi-v7a, x86_64


- Edit-file: `nano user-config.jam`

Add:
```
# armeabi-v7a
using clang : armeabi
    : /root/Android/Sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
    :
    <compileflags>--target=armv7a-linux-androideabi21
    <linkflags>--target=armv7a-linux-androideabi21
;

# arm64-v8a
using clang : arm64
    : /root/Android/Sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
    :
    <compileflags>--target=aarch64-linux-android21
    <linkflags>--target=aarch64-linux-android21
;

# x86_64
using clang : x86_64
    : /root/Android/Sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++
    :
    <compileflags>--target=x86_64-linux-android21
    <linkflags>--target=x86_64-linux-android21
;  ```

## Build Boost for  Android:

armeabi-v7a
```
./b2 --clean-all

./b2 toolset=clang-armeabi \
  --user-config=./user-config.jam \
  target-os=android \
  --prefix=./stage/armeabi-v7a \
  install -j$(nproc)
  ```

arm64-v8a
```
./b2 --clean-all

./b2 toolset=clang-arm64 \
  --user-config=./user-config.jam \
  target-os=android \
  --prefix=./stage/arm64-v8a \
  install -j$(nproc)
  ```

x86_64
```
./b2 --clean-all

./b2 toolset=clang-arm64 \
  --user-config=./user-config.jam \
  target-os=android \
  --prefix=./stage/arm64-v8a \
  install -j$(nproc)
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



