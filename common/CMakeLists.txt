add_library(common
    beldex.cpp
    beldex.h
)

target_include_directories(common PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_link_libraries(common PRIVATE epee)
