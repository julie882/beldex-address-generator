# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2")
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CRYPTO_SOURCES
    crypto.cpp
    crypto-ops.c
    crypto-ops-data.c
    hash.c
    keccak.c
    random.c
)

add_library(cncrypto SHARED ${CRYPTO_SOURCES})

# set_target_properties(cncrypto PROPERTIES
#     POSITION_INDEPENDENT_CODE ON
# )

target_include_directories(cncrypto PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(cncrypto PUBLIC epee)