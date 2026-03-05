#pragma once
#include <type_traits>
#include "epee/span.h" // epee

namespace tools {

  template <typename T, typename = std::enable_if_t<
    !std::is_const_v<T> && (std::is_trivially_copyable_v<T> || epee::is_byte_spannable<T>)
  >>
  bool hex_to_type(std::string_view hex, T& x) {
    if (hex.size() != 2*sizeof(T))
      return false;

    auto hex_char_to_int = [](char c) -> int {
      if (c >= '0' && c <= '9') return c - '0';
      if (c >= 'a' && c <= 'f') return c - 'a' + 10;
      if (c >= 'A' && c <= 'F') return c - 'A' + 10;
      return -1;
    };

    for (char c : hex)
      if (hex_char_to_int(c) < 0)
        return false;

    auto* out = reinterpret_cast<unsigned char*>(&x);

    for (size_t i = 0; i < sizeof(T); ++i) {
      int hi = hex_char_to_int(hex[2*i]);
      int lo = hex_char_to_int(hex[2*i+1]);
      out[i] = static_cast<unsigned char>((hi << 4) | lo);
    }

    return true;
  }

  template <typename T, typename = std::enable_if_t<
      (std::is_standard_layout_v<T> && std::has_unique_object_representations_v<T>)
      || epee::is_byte_spannable<T>
  >>
  std::string type_to_hex(const T& val) {
    static constexpr char hexmap[] = "0123456789abcdef";
    return std::string([&]{
      const unsigned char* data =
          reinterpret_cast<const unsigned char*>(&val);
      std::string result;
      result.reserve(sizeof(val) * 2);
      for (size_t i = 0; i < sizeof(val); ++i) {
        result.push_back(hexmap[data[i] >> 4]);
        result.push_back(hexmap[data[i] & 0x0F]);
      }
      return result;
    }());
  }

}
