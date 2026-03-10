add_library(mnemonics
    electrum-words.cpp
    # electrum-words.h
    # chinese_simplified.h
    # dutch.h
    # english.h
    # english_old.h
    # esperanto.h
    # french.h
    # german.h
    # italian.h
    # japanese.h
    # language_base.h
    # lojban.h
    # portuguese.h
    # russian.h
    # singleton.h
    # spanish.h
)

target_include_directories(mnemonics PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)

target_link_libraries(mnemonics PRIVATE epee common)
