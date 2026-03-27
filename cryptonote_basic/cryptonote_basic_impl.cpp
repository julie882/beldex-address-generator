#include <iostream>
#include <iomanip>
#include <cstring>
#include "cryptonote_basic_impl.h"
#include "common/base58.h"

namespace cryptonote
{

std::string get_account_address_as_str(const account_public_address& adr)
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
    // Example prefixes (adjust based on your coin config!)
    const uint64_t MAINNET_PUBLIC = 0xd1;
    const uint64_t MAINNET_INTEGRATED = 19;
    const uint64_t MAINNET_SUB = 42;

    const uint64_t TESTNET_PUBLIC = 53;
    const uint64_t TESTNET_INTEGRATED = 54;
    const uint64_t TESTNET_SUB = 63;

    const uint64_t DEVNET_PUBLIC = 24;
    const uint64_t DEVNET_INTEGRATED = 25;
    const uint64_t DEVNET_SUB = 36;

    std::string data;
    uint64_t prefix{0};

    if (!tools::base58::decode_addr(str, prefix, data))
    {
        std::cout << "Invalid address format" << std::endl;
        return false;
    }

    std::cout << " prifix: " << prefix << std::endl;
    //  Detect network + type
    if (prefix == MAINNET_PUBLIC)
    {
        nettype = MAINNET;
        info.is_subaddress = false;
        info.has_payment_id = false;
    }
    else if (prefix == MAINNET_INTEGRATED)
    {
        nettype = MAINNET;
        info.is_subaddress = false;
        info.has_payment_id = true;
    }
    else if (prefix == MAINNET_SUB)
    {
        nettype = MAINNET;
        info.is_subaddress = true;
        info.has_payment_id = false;
    }
    else if (prefix == TESTNET_PUBLIC)
    {
        nettype = TESTNET;
        info.is_subaddress = false;
        info.has_payment_id = false;
    }
    else if (prefix == TESTNET_INTEGRATED)
    {
        nettype = TESTNET;
        info.is_subaddress = false;
        info.has_payment_id = true;
    }
    else if (prefix == TESTNET_SUB)
    {
        nettype = TESTNET;
        info.is_subaddress = true;
        info.has_payment_id = false;
    }
    else if (prefix == DEVNET_PUBLIC)
    {
        nettype = DEVNET;
        info.is_subaddress = false;
        info.has_payment_id = false;
    }
    else if (prefix == DEVNET_INTEGRATED)
    {
        nettype = DEVNET;
        info.is_subaddress = false;
        info.has_payment_id = true;
    }
    else if (prefix == DEVNET_SUB)
    {
        nettype = DEVNET;
        info.is_subaddress = true;
        info.has_payment_id = false;
    }
    else
    {
        std::cout << "Unknown address prefix: " << prefix << std::endl;
        return false;
    }

    const size_t key_size = sizeof(info.address.m_spend_public_key);
    const size_t base_size = key_size * 2;
    const size_t payment_id_size = sizeof(info.payment_id);

    size_t expected_size = base_size + (info.has_payment_id ? payment_id_size : 0);

    if (data.size() != expected_size)
    {
        std::cout << "Invalid address size" << std::endl;
        return false;
    }

    // Spend key
    memcpy(&info.address.m_spend_public_key, data.data(), key_size);

    // View key
    memcpy(&info.address.m_view_public_key, data.data() + key_size, key_size);

    // Payment ID
    if (info.has_payment_id)
    {
        memcpy(&info.payment_id, data.data() + base_size, payment_id_size);
    }

    return true;
}

}