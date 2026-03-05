cmake_minimum_required(VERSION 3.10)
project(AddressGenerator)

if(ANDROID)
    message(STATUS `Building andriod .......... ${ANDROID}`)
    set(BOOST_ROOT "${CMAKE_SOURCE_DIR}/boost_1_83_0")
    set(BOOST_INCLUDE_DIR "${BOOST_ROOT}/")  # root has all headers like boost/crc.hpp
    set(BOOST_LIB_DIR "${BOOST_ROOT}/stage/${ANDROID_ABI}/lib")
    include_directories(${BOOST_INCLUDE_DIR})

    foreach(lib system thread serialization program_options atomic date_time)
        add_library(Boost::${lib} STATIC IMPORTED)
        set_target_properties(Boost::${lib} PROPERTIES
            IMPORTED_LOCATION "${BOOST_LIB_DIR}/libboost_${lib}.a"
        )
    endforeach()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(NOT ANDROID)
find_package(Boost 1.62 REQUIRED COMPONENTS system thread serialization program_options atomic date_time)
if(NOT Boost_FOUND)
  message(FATAL_ERROR "Could not find Boost libraries, please make sure you have installed Boost or libboost-all-dev (>=1.58) or the equivalent")
else(Boost_FOUND)
  message(STATUS "Found Boost Version: ${Boost_VERSION}")
endif()
  include_directories(${Boost_INCLUDE_DIRS})
endif()

add_subdirectory(epee)
add_subdirectory(common)
add_subdirectory(crypto)
add_subdirectory(mnemonics)
add_subdirectory(wallet)
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
        cryptonote_basic
        wallet
        common
        cncrypto
        epee 
        mnemonics
        Boost::serialization
        Boost::thread
        Boost::program_options
        Boost::date_time
        Boost::atomic
)
