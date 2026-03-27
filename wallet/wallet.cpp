#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstring>
#include <epee/wipeable_string.h>
#include <crypto/crypto.h>
#include <mnemonics/electrum-words.h>
#include "cryptonote_basic/cryptonote_basic.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"

extern "C"
{
#include "crypto/keccak.h"
}
#include "wallet.h"


struct account_keys
{
    crypto::secret_key m_spend_secret_key;
    crypto::secret_key m_view_secret_key;
    cryptonote::account_public_address m_account_address;
};

struct wallet;

account_keys generate(const crypto::secret_key& recovery_key, bool recover, bool two_random)
{
    account_keys m_keys{};
    crypto::generate_keys(m_keys.m_account_address.m_spend_public_key, m_keys.m_spend_secret_key, recovery_key, recover);
    crypto::secret_key second;
    keccak((uint8_t *)&m_keys.m_spend_secret_key, sizeof(crypto::secret_key), (uint8_t *)&second, sizeof(crypto::secret_key));
    
    crypto::generate_keys(m_keys.m_account_address.m_view_public_key, m_keys.m_view_secret_key, second, two_random ? false : true);

    return m_keys;
} 

wallet restore_wallet(const std::string& input_seed)
{
    wallet w;
    crypto::secret_key seed_key;
    std::string language;

    if(!crypto::ElectrumWords::words_to_bytes(input_seed, seed_key, language))
    {
        std::cout<<"Invalid seed: failed to convert words to bytes"<<std::endl;
        return w;
    }
    account_keys keys = generate(seed_key, true, false);
    cryptonote::account_public_address adr;

    std::memcpy(
        &adr.m_spend_public_key,
        &keys.m_account_address.m_spend_public_key,
        32);

    std::memcpy(
        &adr.m_view_public_key,
        &keys.m_account_address.m_view_public_key,
        32);

    w.address = cryptonote::get_account_address_as_str(
                    adr);

    std::stringstream ss(std::string(input_seed.data(), input_seed.size()));
    std::string word;

    while (ss >> word)
    {
        w.seed.push_back(word);
    }

    // Store Keys
    w.spend_pub = epee::to_hex::string(epee::as_byte_span(keys.m_account_address.m_spend_public_key));
    w.view_pub = epee::to_hex::string(epee::as_byte_span(keys.m_account_address.m_view_public_key));
    w.private_spend_key = epee::to_hex::string(epee::as_byte_span(keys.m_spend_secret_key));
    w.private_view_key = epee::to_hex::string(epee::as_byte_span(keys.m_view_secret_key));

    return w;
}

wallet generate_new_wallet()
{
    wallet w;
    account_keys keys = generate(crypto::secret_key(), false, false);
    epee::wipeable_string seed;
    crypto::ElectrumWords::bytes_to_words(keys.m_spend_secret_key, seed, "English");

    std::stringstream ss(std::string(seed.data(), seed.size()));
    std::string word;

    while (ss >> word)
    {
        w.seed.push_back(word);
    }

    cryptonote::account_public_address adr;
    std::memcpy(&adr.m_spend_public_key, &keys.m_account_address.m_spend_public_key, 32);
    std::memcpy(&adr.m_view_public_key, &keys.m_account_address.m_view_public_key, 32);

    w.address =cryptonote::get_account_address_as_str(adr);

    // Store Keys
    w.spend_pub = epee::to_hex::string(epee::as_byte_span(keys.m_account_address.m_spend_public_key));
    w.view_pub = epee::to_hex::string(epee::as_byte_span(keys.m_account_address.m_view_public_key));
    w.private_spend_key = epee::to_hex::string(epee::as_byte_span(keys.m_spend_secret_key));
    w.private_view_key = epee::to_hex::string(epee::as_byte_span(keys.m_view_secret_key));

    return w;               

} 

address_info validate_address(const std::string& address)
{
    address_info result{};
    cryptonote::address_parse_info info;

    cryptonote::network_type nettype = cryptonote::MAINNET;
    bool valid = false;

    for (cryptonote::network_type nt : {cryptonote::MAINNET, cryptonote::TESTNET, cryptonote::DEVNET})
    {
        if (cryptonote::get_account_address_from_str(info, nt, address))
        {
            nettype = nt;
            valid = true;
            break;
        }
    }

    result.valid = valid;

    if (!valid)
    {
        result.type = "invalid";
        return result;
    }

    // Type
    if (info.is_subaddress)
        result.type = "subaddress";
    else if (info.has_payment_id)
        result.type = "integrated";
    else
        result.type = "standard";

    // Network
    if (nettype == cryptonote::MAINNET) result.network = "mainnet";
    else if (nettype == cryptonote::TESTNET) result.network = "testnet";
    else if (nettype == cryptonote::DEVNET) result.network = "devnet";

    // Keys
    const auto& addr = info.address;
    result.spend_public_key = epee::to_hex::string(epee::as_byte_span(addr.m_spend_public_key));
    result.view_public_key  = epee::to_hex::string(epee::as_byte_span(addr.m_view_public_key));

    // Payment ID (NO string_tools)
    if (info.has_payment_id)
    {
        result.payment_id = epee::to_hex::string(epee::as_byte_span(info.payment_id));
    }

    return result;
}