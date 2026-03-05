#pragma once

#include <cstdint>
#include <string>
#include <string_view>

namespace tools
{
  namespace base58
  {
    std::string encode_addr(std::string_view data);
    bool decode(std::string_view enc, std::string& data);

    std::string encode_addr(uint64_t tag, std::string_view data);
    bool decode_addr(std::string_view addr, uint64_t& tag, std::string& data);
  }
}