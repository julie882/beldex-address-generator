add_library(cryptonote_basic STATIC
  cryptonote_basic_impl.cpp
  cryptonote_basic.h
)

target_link_libraries(cryptonote_basic PRIVATE
   common
    Boost::serialization
)
