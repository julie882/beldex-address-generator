#pragma once

#include <cstddef>
#include <ostream>
#include "generic-ops.h"
#include "common/hex.h"
#include "cn_heavy_hash.hpp"



  extern "C" {
#include "hash-ops.h"
void cn_fast_hash(const void *data, size_t length, char *hash);
  }
  namespace crypto {

  struct alignas(size_t) hash {
    char data[HASH_SIZE];
    static constexpr hash null() { 
      return {0};
   }
    operator bool() const { return memcmp(data, null().data, sizeof(data)); 
    }
  };
  struct hash8 {
    char data[8];
  };

  static_assert(sizeof(hash) == HASH_SIZE, "Invalid structure size");
  static_assert(sizeof(hash8) == 8, "Invalid structure size");

  /*
    Cryptonight hash functions
  */

  // inline void cn_fast_hash(const void *data, std::size_t length, hash &hash) {
  //   cn_fast_hash(data, length, reinterpret_cast<char *>(&hash));
  // }

  // inline hash cn_fast_hash(const void *data, std::size_t length) {
  //   hash h;
  //   cn_fast_hash(data, length, reinterpret_cast<char *>(&h));
  //   return h;
  // }

  inline void cn_fast_hash(const void *data, std::size_t length, hash &h)
  {
      ::cn_fast_hash(data, length, h.data);
  }
  
  inline hash cn_fast_hash(const void *data, std::size_t length)
  {
      hash h;
      ::cn_fast_hash(data, length, h.data);
      return h;
  }




  enum struct cn_slow_hash_type
  {
#ifdef ENABLE_MONERO_SLOW_HASH
    // NOTE: Monero's slow hash for Android only, we still use the old hashing algorithm for hashing the KeyStore containing private keys
    cryptonight_v0,
    cryptonight_v0_prehashed,
    cryptonight_v1_prehashed,
#endif

    heavy_v1,
    heavy_v2,
    turtle_lite_v2,
  };

  
//   inline void cn_slow_hash(const void *data, std::size_t length, hash &hash, cn_slow_hash_type type) {
//     switch(type)
//     {
//       case cn_slow_hash_type::heavy_v1:
//       case cn_slow_hash_type::heavy_v2:
//       {
//         static thread_local cn_heavy_hash_v2 v2;
//         static thread_local cn_heavy_hash_v1 v1 = cn_heavy_hash_v1::make_borrowed(v2);

//         if (type == cn_slow_hash_type::heavy_v1) v1.hash(data, length, hash.data);
//         else                                     v2.hash(data, length, hash.data);
//       }
//       break;

// #ifdef ENABLE_MONERO_SLOW_HASH
//       case cn_slow_hash_type::cryptonight_v0:
//       case cn_slow_hash_type::cryptonight_v1_prehashed:
//       {
//         int variant = 0, prehashed = 0;
//         if (type == cn_slow_hash_type::cryptonight_v1_prehashed)
//         {
//           prehashed = 1;
//           variant   = 1;
//         }
//         else if (type == cn_slow_hash_type::cryptonight_v0_prehashed)
//         {
//           prehashed = 1;
//         }

//         cn_monero_hash(data, length, hash.data, variant, prehashed);
//       }
//       break;
// #endif

//       case cn_slow_hash_type::turtle_lite_v2:
//       default:
//       {
//          const uint32_t CN_TURTLE_SCRATCHPAD = 262144;
//          const uint32_t CN_TURTLE_ITERATIONS = 131072;
//          cn_turtle_hash(data,
//              length,
//              hash.data,
//              1, // light
//              2, // variant
//              0, // pre-hashed
//              CN_TURTLE_SCRATCHPAD, CN_TURTLE_ITERATIONS);
//       }
//       break;
//     }
//   }

  // inline void tree_hash(const hash *hashes, std::size_t count, hash &root_hash) {
  //   tree_hash(reinterpret_cast<const char (*)[HASH_SIZE]>(hashes), count, reinterpret_cast<char *>(&root_hash));
  // }

  constexpr size_t SIZE_TS_IN_HASH = sizeof(crypto::hash) / sizeof(size_t);
  static_assert(SIZE_TS_IN_HASH * sizeof(size_t) == sizeof(crypto::hash) && alignof(crypto::hash) >= alignof(size_t),
      "Expected crypto::hash size/alignment not satisfied");

  // Combine hashes together via XORs.
  inline crypto::hash& operator^=(crypto::hash& a, const crypto::hash& b) {
    size_t (&dest)[SIZE_TS_IN_HASH] = reinterpret_cast<size_t (&)[SIZE_TS_IN_HASH]>(a);
    const size_t (&src)[SIZE_TS_IN_HASH] = reinterpret_cast<const size_t (&)[SIZE_TS_IN_HASH]>(b);
    for (size_t i = 0; i < SIZE_TS_IN_HASH; ++i)
      dest[i] ^= src[i];
    return a;
  }
  inline crypto::hash operator^(const crypto::hash& a, const crypto::hash& b) {
    crypto::hash c = a;
    c ^= b;
    return c;
  }

  
  constexpr inline crypto::hash null_hash = {};
  constexpr inline crypto::hash8 null_hash8 = {};
}

CRYPTO_MAKE_HASHABLE(hash)
CRYPTO_MAKE_COMPARABLE(hash8)

