cmake_minimum_required(VERSION 3.10)
project(AddressGenerator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(generateaddress main.cpp)

find_package(Boost 1.62 QUIET REQUIRED COMPONENTS system thread serialization program_options)
if(NOT Boost_FOUND)
  message(FATAL_ERROR "Could not find Boost libraries, please make sure you have installed Boost or libboost-all-dev (>=1.58) or the equivalent")
elseif(Boost_FOUND)
  message(STATUS "Found Boost Version: ${Boost_VERSION}")
endif()

add_subdirectory(epee)
add_subdirectory(common)
add_subdirectory(crypto)
# add_subdirectory(serialization)
# add_subdirectory(mnemonics)

target_link_libraries(generateaddress 
    PRIVATE 
        epee 
        cncrypto 
        common
        Boost::serialization
        Boost::program_options
        )