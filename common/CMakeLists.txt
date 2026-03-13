add_library(common STATIC
    beldex.cpp
    beldex.h
    base58.cpp
)

target_include_directories(common PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
   # ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_link_libraries(common PUBLIC cncrypto epee)
