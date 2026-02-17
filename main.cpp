#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <epee/wipeable_string.h>
#include <crypto/crypto.h>

// #include "serialization/binary_utils.h"
// #include "serialization/container.h"

extern "C"
{
#include "crypto/keccak.h"
}

// #include <mnemonics/electrum-words.h>

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
struct account_keys {
    crypto::secret_key m_spend_secret_key;
    crypto::secret_key m_view_secret_key;
    account_public_address m_account_address;
};

std::string get_account_address_as_str(const account_public_address& address) {
    uint64_t address_prefix = 0xd1; // Beldex mainnet address prefix
    // return tools::base58::encode_addr(address_prefix, t_serializable_object_to_blob(address));
}

account_keys generate(const crypto::secret_key& recovery_key, bool recover, bool two_random)
{
    account_keys m_keys{};
    crypto::secret_key first = crypto::generate_keys(m_keys.m_account_address.m_spend_public_key, m_keys.m_spend_secret_key, recovery_key, recover);
    crypto::secret_key second;
    keccak((uint8_t *)&m_keys.m_spend_secret_key, sizeof(crypto::secret_key), (uint8_t *)&second, sizeof(crypto::secret_key));
    
    crypto::generate_keys(m_keys.m_account_address.m_view_public_key, m_keys.m_view_secret_key, second, two_random ? false : true);

    return m_keys;
}
void generate_address() {
    std::cout << "Generating new address" << std::endl;

    account_keys keys = generate(crypto::secret_key(), false, false);
    

    std::cout << "The keys are: ------------------" << std::endl;
    std::cout << "spend:" << std::endl;
    std::cout << "Secret: " << keys.m_spend_secret_key << std::endl;
    std::cout << "Public: " <<keys.m_account_address.m_spend_public_key << std::endl;

    std::cout << "view:" << std::endl;
    std::cout << "Secret: " << keys.m_view_secret_key << std::endl;
    std::cout << "Public: " << keys.m_account_address.m_view_public_key << std::endl;

    std::string address = get_account_address_as_str(keys.m_account_address);
    
    std::cout << "Address: " << address << std::endl;
}

void restore_address(epee::wipeable_string seed) {
    std::cout << "Restoring address from seed" << std::endl;

    
    // std::vector<std::string> words;
    // std::stringstream ss(seed);
    // std::string word;
    // while (ss >> word) {
    //     words.push_back(word);
    // }
    // std::cout << "Parsed " << words.size() << " words." << std::endl;

    // crypto::secret_key m_recovery_key;
    // std::string old_language;
    // if (!crypto::ElectrumWords::words_to_bytes(seed, m_recovery_key, old_language)) {
    //     std::cout << "Failed to restore address from seed" << std::endl;
    // }

}


int main(int argc, char* argv[]) {
    std::cout << "Address Generator" << std::endl;

    std::string seed;

    std::cout << "Enter seed: ";

    std::getline(std::cin, seed);

    epee::wipeable_string wipeable_seed(seed);

    if( wipeable_seed.empty() ) {
        std::cout << "Seed is empty so generating new address" << std::endl;
        generate_address();
    } else {
        std::cout << "Restoring address from seed" << std::endl;
        restore_address(wipeable_seed);
    }

}
