#pragma once
#pragma once

#include "crypto/crypto.h"
#include "crypto/hash.h"
#include "cryptonote_basic.h"

namespace cryptonote
{

  enum network_type : uint8_t
  {
    MAINNET = 0,
    TESTNET,
    DEVNET,
  };

  std::string get_account_address_as_str(
      const account_public_address& adr);


  bool get_account_address_from_str(
        address_parse_info& info,
        network_type nettype,
        const std::string_view str
    );    
}   