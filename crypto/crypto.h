#pragma once

#include <cstddef>
#include "epee/wipeable_string.h"
#include "epee/span.h"
#include "epee/hex.h"

namespace crypto {

  extern "C" {
    #include "random.h"
  }

  struct alignas(size_t) ec_point {
    char data[32];
    // Returns true if non-null, i.e. not 0.
    operator bool() const { static constexpr char null[32] = {0}; return memcmp(data, null, sizeof(data)); }
  };

  struct alignas(size_t) ec_scalar {
    char data[32];
  };

  struct public_key : ec_point {};

  using secret_key = ec_scalar;

   /* Generate a new key pair
   */
  secret_key generate_keys(public_key &pub, secret_key &sec, const secret_key& recovery_key = secret_key(), bool recover = false);

  inline std::ostream &operator <<(std::ostream &o, const crypto::public_key &v) {
    epee::to_hex::formatted(o, epee::as_byte_span(v));
    return o;
  }

  inline std::ostream &operator <<(std::ostream &o, const crypto::secret_key &v) {
    epee::to_hex::formatted(o, epee::as_byte_span(v));
    return o;
  }

}
