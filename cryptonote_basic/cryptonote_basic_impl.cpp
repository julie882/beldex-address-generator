#include "cryptonote_basic_impl.h"
#include "common/base58.h"
#include "iostream"

struct network_config{
  uint64_t PUBLIC_ADDRESS_BASE58_PREFIX;
  uint64_t PUBLIC_INTEGRATED_ADDRESS_BASE58_PREFIX;
  uint64_t PUBLIC_SUBADDRESS_BASE58_PREFIX;
};

namespace cryptonote
{
    struct address_parse_info;

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
    
        bool get_account_address_from_str(
            address_parse_info& info,
            network_type nettype,
            const std::string_view str)
        {
            struct address_prefixes {
                uint64_t address;
                uint64_t integrated;
                uint64_t subaddress;
            };
        
            // Define prefixes at namespace/block scope
            constexpr address_prefixes MAINNET_PREFIXES  { 0xd1, 19, 42 };
            constexpr address_prefixes TESTNET_PREFIXES  { 53, 54, 63 };
            constexpr address_prefixes DEVNET_PREFIXES   { 24, 25, 36 };
        
            // Select the right network prefix
            const address_prefixes* conf = nullptr;
            switch(nettype) {
                case MAINNET: conf = &MAINNET_PREFIXES; break;
                case TESTNET: conf = &TESTNET_PREFIXES; break;
                case DEVNET:  conf = &DEVNET_PREFIXES;  break;
                default: return false;
            }
        
            uint64_t address_prefix = conf->address;
            uint64_t integrated_address_prefix = conf->integrated;
            uint64_t subaddress_prefix = conf->subaddress;
        
            // Decode Base58
            blobdata data;
            uint64_t prefix{0};
            if (!tools::base58::decode_addr(str, prefix, data))
            {
                std::cout<<"Invalid address format"<<std::endl;
                return false;
            }
        
            if(data.size() < 64) {
                std::cout<<"Address data too short"<<std::endl;
                return false;
            }
        
            memcpy(&info.address.m_spend_public_key, data.data(), 32);
            memcpy(&info.address.m_view_public_key, data.data() + 32, 32);
        
            // Check prefix
            if (prefix == integrated_address_prefix)
            {
                info.is_subaddress = false;
                info.has_payment_id = true;
            }
            else if (prefix == address_prefix)
            {
                info.is_subaddress = false;
                info.has_payment_id = false;
            }
            else if (prefix == subaddress_prefix)
            {
                info.is_subaddress = true;
                info.has_payment_id = false;
            }
            else {
                std::cout<<"Wrong address prefix: " << prefix 
                         << ", expected " << address_prefix 
                         << " or " << integrated_address_prefix
                         << " or " << subaddress_prefix << std::endl;
                return false;
            }
        
            // Validate keys
            if (!crypto::check_key(info.address.m_spend_public_key) ||
                !crypto::check_key(info.address.m_view_public_key))
            {
                std::cout<<"Failed to validate address keys"<<std::endl;
                return false;
            }
        
            return true;
        }
    }