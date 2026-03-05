#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstring>
#include <epee/wipeable_string.h>
#include <crypto/crypto.h>
#include <mnemonics/electrum-words.h>
#include <iomanip>
#include "cryptonote_basic/cryptonote_basic.h"
extern "C"
{
#include "crypto/keccak.h"
}
#include <string>
#include <vector>
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
    crypto::secret_key first = crypto::generate_keys(m_keys.m_account_address.m_spend_public_key, m_keys.m_spend_secret_key, recovery_key, recover);
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
    crypto::ElectrumWords::words_to_bytes(input_seed, seed_key, language);
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
    return w;               

}


std::string key_to_hex(const void* data, size_t size)
{
    const unsigned char* bytes = static_cast<const unsigned char*>(data);

    std::ostringstream oss;
    oss << std::hex << std::setfill('0');

    for (size_t i = 0; i < size; i++)
        oss << std::setw(2) << (int)bytes[i];

    return oss.str();
} 

std::string create_wallet_address(const crypto::public_key &spend_pub,
    const crypto::public_key &view_pub)
{
    std::vector<unsigned char> data;
    data.push_back(0xd1); // mainnet prefix

    data.insert(data.end(), spend_pub.data, spend_pub.data + 32);
    data.insert(data.end(), view_pub.data, view_pub.data + 32);

}
