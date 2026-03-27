#pragma once

#include <vector>
#include <sstream>
#include <atomic>

#include "cryptonote_basic.h"
#include "crypto/crypto.h"
#include "crypto/hash.h"

using blobdata = std::string;

 namespace cryptonote
 {
    struct account_public_address
    {
      crypto::public_key m_spend_public_key;
      crypto::public_key m_view_public_key;


      bool operator==(const account_public_address& rhs) const
     {
      return m_spend_public_key == rhs.m_spend_public_key &&
      m_view_public_key == rhs.m_view_public_key;
     }

    bool operator!=(const account_public_address& rhs) const
    {
      return !(*this == rhs); 
    }
    };
    inline constexpr account_public_address nulladdress(); 

    struct address_parse_info
    {
        account_public_address address;
        bool is_subaddress;
        bool has_payment_id;
        crypto::hash8 payment_id;
    };

    struct integrated_address
    {
        account_public_address adr;
        crypto::hash8 payment_id;
    };

std::string get_account_address_as_str(
  const account_public_address& adr);

 };
