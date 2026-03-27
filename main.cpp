#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include "wallet/wallet.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"
#include "cryptonote_basic/cryptonote_basic.h"
//#include "epee/string_tools.h"

template <typename T>
std::string to_hex(const T& data)
{
    const uint8_t* ptr = reinterpret_cast<const uint8_t*>(&data);
    std::ostringstream oss;

    for (size_t i = 0; i < sizeof(T); ++i)
    {
        oss << std::hex << std::setw(2) << std::setfill('0')
            << static_cast<int>(ptr[i]);
    }

    return oss.str();
}

int main(int argc, char* argv[]) {

    // std::cout << "Address Generator" << std::endl;
    // std::cout<< " Enter seed : ";
    // std::string input;
    // std::getline(std::cin,input);
    // wallet w;
    // if(input.empty())
    // {
    //     w=generate_new_wallet();
    // }
    // else{
    //     std::cout << "Restoring wallet from seed...\n";
    //     //epee::wipeable_string wipeable_seed(input);
    //     w = restore_wallet(input);
    // }

    // std::cout <<" Mnemonic Seed: " << std::endl; 
    // for(const auto& word : w.seed)
    // {
    //     std::cout<< word <<" ";
    // }
    // std::cout<<std::endl;
    // std::string address = w.address;
    // std::cout << "Wallet Address: " << address << std::endl;       
    // std::cout << "Spend Public Key: " << w.spend_pub << std::endl;
    // std::cout << "View Public Key: " << w.view_pub << std::endl;
    // std::cout << "Private Spend Key: " << w.private_spend_key << std::endl;
    // std::cout << "Private View Key: " << w.private_view_key << std::endl;

    
    
    std::string input_address;
    std::cout << "Enter address: ";
    std::cin >> input_address;

    cryptonote::address_parse_info info;
    cryptonote::network_type nettype;
    bool valid = false;

    // network types
    for (auto nt : {cryptonote::MAINNET, cryptonote::TESTNET, cryptonote::DEVNET})
    {

        if (cryptonote::get_account_address_from_str(info, nt, input_address))
        {
            nettype = nt;
            valid = true;
            break;
        }
    }

    if (!valid)
    {
        std::cout << "Address is INVALID" << std::endl;
        return 0;
    }

    std::cout << "Address is VALID" << std::endl;

    //  Address type
    if (info.is_subaddress)
        std::cout << "Subaddress" << std::endl;
    else if (info.has_payment_id)
        std::cout << "Integrated Address" << std::endl;
    else
        std::cout << "Standard Address" << std::endl;

    // Network
    if (nettype == cryptonote::MAINNET) std::cout << "MAINNET\n";
    else if (nettype == cryptonote::TESTNET) std::cout << "TESTNET\n";
    else if (nettype == cryptonote::DEVNET) std::cout << "DEVNET\n";

    // Keys
    auto& addr = info.address;
    std::cout << "Spend: " << to_hex(addr.m_spend_public_key) << "\n";
    std::cout << "View : " << to_hex(addr.m_view_public_key) << "\n";
    
    return 0;
}
        
