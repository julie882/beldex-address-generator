#include <iostream>
#include <mutex>
#include <unistd.h>
#include <cassert>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <memory>
#include <stdexcept>

#include "crypto.h"

extern "C"
{
#include "keccak.h"
}

// using namespace crypto; // REMOVED

namespace crypto
{

  using std::abort;
  using std::int32_t;
  using std::int64_t;
  using std::size_t;
  using std::uint32_t;
  using std::uint64_t;

  extern "C"
  {
    #include "crypto-ops.h"
    #include "random.h"
  }

  // EW!
  static inline unsigned char *operator&(ec_point &point)
  {
    return &reinterpret_cast<unsigned char &>(point);
  }

  // EW!
  static inline const unsigned char *operator&(const ec_point &point)
  {
    return &reinterpret_cast<const unsigned char &>(point);
  }

  // EW!
  static inline unsigned char *operator&(ec_scalar &scalar)
  {
    return &reinterpret_cast<unsigned char &>(scalar);
  }

  // EW!
  static inline const unsigned char *operator&(const ec_scalar &scalar)
  {
    return &reinterpret_cast<const unsigned char &>(scalar);
  }

  static std::mutex random_mutex;

  // 2^252+27742317777372353535851937790883648493
  static constexpr unsigned char L[32] = {
      0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58, 0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10};

  // Returns true iff 32-byte, little-endian unsigned integer a is less than L
  static inline bool sc_is_canonical(const unsigned char *a)
  {
    for (size_t n = 31; n < 32; --n)
    {
      if (a[n] < L[n])
        return true;
      if (a[n] > L[n])
        return false;
    }
    return false;
  }

  void random_scalar(unsigned char *bytes)
  {
    std::lock_guard lock{random_mutex};
    do
    {
      generate_random_bytes_not_thread_safe(32, bytes);
      bytes[31] &= 0b0001'1111; // Mask the 3 most significant bits off because no acceptable value ever has them set (the value would be >L)
    } while (!(sc_is_canonical(bytes) && sc_isnonzero(bytes)));
  }

  /* generate a random ]0..L[ scalar */
  void random_scalar(ec_scalar &res)
  {
    random_scalar(reinterpret_cast<unsigned char *>(res.data));
  }

  /*
   * generate public and secret keys from a random 256-bit integer
   */
  secret_key generate_keys(public_key &pub, secret_key &sec, const secret_key &recovery_key, bool recover)
  {
    ge_p3 point;

    secret_key rng;

    if (recover)
    {
      rng = recovery_key;
    }
    else
    {
      random_scalar(rng);
    }
    sec = rng;
    sc_reduce32(&sec); // reduce in case second round of keys (sendkeys)

    ge_scalarmult_base(&point, &sec);
    ge_p3_tobytes(&pub, &point);

    return rng;
  }

} // namespace crypto