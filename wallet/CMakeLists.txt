set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(WALLET_LIBRARY_TYPE SHARED)
if(CMAKE_SYSTEM_NAME MATCHES "iOS|Linux")
    set(WALLET_LIBRARY_TYPE STATIC)
endif()

add_library(wallet ${WALLET_LIBRARY_TYPE}
    wallet.cpp
    ffi_interface.cpp
)

#Static library
# add_library(wallet_static STATIC
#     wallet.cpp
#     ffi_interface.cpp
# )

target_include_directories(wallet PUBLIC ${CMAKE_SOURCE_DIR})
#target_include_directories(wallet_static PUBLIC ${CMAKE_SOURCE_DIR})

target_link_libraries(wallet
    PUBLIC
        cncrypto
        epee
        mnemonics
        common
        cryptonote_basic
        Boost::atomic
        Boost::date_time
        Boost::serialization
        Boost::system
        Boost::thread
)
