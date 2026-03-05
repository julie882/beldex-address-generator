#pragma once

#include <cstddef>
#include <cstring>
#include <functional>
//#include <sodium/crypto_verify_32.h>

#define CRYPTO_MAKE_COMPARABLE(type) \
namespace crypto { \
  inline bool operator==(const type &_v1, const type &_v2) { \
    return !memcmp(&_v1, &_v2, sizeof(_v1)); \
  } \
  inline bool operator!=(const type &_v1, const type &_v2) { \
    return !operator==(_v1, _v2); \
  } \
  inline bool operator<(const type &_v1, const type &_v2) { \
    return memcmp(&_v1, &_v2, sizeof(_v1)) < 0; \
  } \
}

#define CRYPTO_MAKE_COMPARABLE_CONSTANT_TIME(type) \
namespace crypto { \
  inline bool operator==(const type &_v1, const type &_v2) { \
    static_assert(sizeof(_v1) == 32, "constant time comparison is only implenmted for 32 bytes"); \
    return crypto_verify_32((const unsigned char*)&_v1, (const unsigned char*)&_v2) == 0; \
  } \
  inline bool operator!=(const type &_v1, const type &_v2) { \
    return !operator==(_v1, _v2); \
  } \
}

#define CRYPTO_DEFINE_HASH_FUNCTIONS(type) \
namespace std { \
  template<> \
  struct hash<crypto::type> { \
    static_assert(sizeof(crypto::type) >= sizeof(std::size_t) && alignof(crypto::type) >= alignof(std::size_t), \
        "Size and alignment of " #type " must be at least that of size_t"); \
    std::size_t operator()(const crypto::type &_v) const { \
      return reinterpret_cast<const std::size_t &>(_v); \
    } \
  }; \
}

#define CRYPTO_MAKE_HASHABLE(type) \
CRYPTO_MAKE_COMPARABLE(type) \
CRYPTO_DEFINE_HASH_FUNCTIONS(type)

#define CRYPTO_MAKE_HASHABLE_CONSTANT_TIME(type) \
CRYPTO_MAKE_COMPARABLE_CONSTANT_TIME(type) \
CRYPTO_DEFINE_HASH_FUNCTIONS(type)

