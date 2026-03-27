cmake_minimum_required(VERSION 3.10)
project(AddressGenerator)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 OLD)
endif()

if(POLICY CMP0074)
    cmake_policy(SET CMP0074 NEW)
endif()

if(POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW)
endif()

if(ANDROID OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
    if(ANDROID)
        message(STATUS "Building android: ${ANDROID}")
        if(EXISTS "${CMAKE_SOURCE_DIR}/boost_1_85_0")
            set(BOOST_ROOT "${CMAKE_SOURCE_DIR}/boost_1_85_0")
        elseif(EXISTS "${CMAKE_SOURCE_DIR}/boost_1_83_0")
            set(BOOST_ROOT "${CMAKE_SOURCE_DIR}/boost_1_83_0")
        else()
            message(FATAL_ERROR "Expected Boost source tree at ${CMAKE_SOURCE_DIR}/boost_1_85_0 or boost_1_83_0 for Android builds.")
        endif()
        set(BOOST_INCLUDE_DIR "${BOOST_ROOT}/")
        set(BOOST_LIB_DIR "${BOOST_ROOT}/stage/${ANDROID_ABI}/lib")
    else()
        if(NOT DEFINED BOOST_ROOT)
            message(FATAL_ERROR "Set BOOST_ROOT to the iOS Boost prefix before configuring the iOS build.")
        endif()
        message(STATUS "Building iOS with Boost from: ${BOOST_ROOT}")
        set(BOOST_INCLUDE_DIR "${BOOST_ROOT}/include")
        set(BOOST_LIB_DIR "${BOOST_ROOT}/lib")
    endif()

    include_directories(${BOOST_INCLUDE_DIR})

    foreach(lib system thread serialization atomic date_time)
        add_library(Boost::${lib} STATIC IMPORTED)
        set_target_properties(Boost::${lib} PROPERTIES
            IMPORTED_LOCATION "${BOOST_LIB_DIR}/libboost_${lib}.a"
        )
    endforeach()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_STATIC_RUNTIME OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT ANDROID AND NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
  find_package(Boost 1.62 REQUIRED COMPONENTS system thread serialization atomic date_time)
  if(NOT Boost_FOUND)
    message(FATAL_ERROR "Could not find Boost libraries, please make sure you have installed Boost or libboost-all-dev (>=1.58) or the equivalent")
  else()
    message(STATUS "Found Boost Version: ${Boost_VERSION}")
  endif()
  include_directories(${Boost_INCLUDE_DIRS})
endif()

add_subdirectory(wallet)
add_subdirectory(epee)
add_subdirectory(common)
add_subdirectory(crypto)
add_subdirectory(mnemonics)
add_subdirectory(cryptonote_basic)

add_executable(generateaddress main.cpp)

target_include_directories(generateaddress PUBLIC
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/wallet
    ${CMAKE_SOURCE_DIR}/epee
    ${CMAKE_SOURCE_DIR}/crypto
    ${CMAKE_SOURCE_DIR}/mnemonics
    ${CMAKE_SOURCE_DIR}/common
    
)


target_link_libraries(generateaddress 
    PRIVATE 
        wallet
)


#if(WIN32 OR (UNIX AND NOT APPLE AND NOT ANDROID))
if(WIN32)
    target_link_options(wallet PRIVATE
        -static
        -static-libgcc
        -static-libstdc++
    )
endif()
