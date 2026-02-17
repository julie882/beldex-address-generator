add_library(epee
    memwipe.c
    wipeable_string.cpp
    memwipe.h
    wipeable_string.h
    int-util.h
    span.h
    hex.cpp
    hex.h
)

target_include_directories(epee PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)
