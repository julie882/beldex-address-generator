add_library(cncrypto
    crypto-ops.c
    crypto-ops-data.c
    crypto.cpp
    hash.c
    keccak.c
    random.c
)

target_link_libraries(cncrypto PRIVATE epee)