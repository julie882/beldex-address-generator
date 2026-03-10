cmake_minimum_required(VERSION 3.10)
set (CMAKE_CXX_STANDARD 17)

add_library( wallet_jni
             SHARED
             ./jni/wallet_jni.cpp)

set(CMAKE_BUILD_TYPE Debug)

set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/../wallet)

add_library(wallet_api STATIC IMPORTED)
set_target_properties(wallet_api PROPERTIES IMPORTED_LOCATION
    ${EXTERNAL_LIBS_DIR}/lib/${ANDROID_ABI}/libwallet_api.a)

include_directories( ${EXTERNAL_LIBS_DIR}/include)

target_link_libraries( wallet_jni PRIVATE wallet_api )
target_include_directories( wallet_jni PRIVATE wallet_api )
target_link_options(wallet_jni PRIVATE "-Wl,-z,max-page-size=16384")
