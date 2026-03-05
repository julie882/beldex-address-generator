set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Shared library
add_library(wallet SHARED
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

target_include_directories(wallet PUBLIC
    ${CMAKE_SOURCE_DIR}
)
target_link_libraries(wallet
    PUBLIC
        cncrypto
        epee
        mnemonics
        common
        cryptonote_basic
        Boost::serialization
        Boost::program_options
        Boost::system
        Boost::thread
)

