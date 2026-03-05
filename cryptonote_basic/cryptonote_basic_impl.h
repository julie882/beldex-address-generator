#pragma once
#pragma once

#include "crypto/crypto.h"
#include "crypto/hash.h"
#include "cryptonote_basic.h"

namespace cryptonote
{

  std::string get_account_address_as_str(
      const account_public_address& adr);

}   