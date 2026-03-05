#include "cryptonote_basic_impl.h"
#include "common/base58.h"


namespace cryptonote
{
  std::string get_account_address_as_str(
        const account_public_address& adr)
        {
        uint64_t address_prefix = 0xd1;
    
        std::string data;
    
        data.reserve(sizeof(adr.m_spend_public_key) + sizeof(adr.m_view_public_key));
    
        data.append(reinterpret_cast<const char*>(&adr.m_spend_public_key),
        sizeof(adr.m_spend_public_key));
    
        data.append(reinterpret_cast<const char*>(&adr.m_view_public_key),
        sizeof(adr.m_view_public_key));
        return tools::base58::encode_addr(address_prefix, data);
        }
 }  