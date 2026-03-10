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
#include "wallet/wallet.cpp"
#include <string>
#include <vector>

int main(int argc, char* argv[]) {

    std::cout << "Address Generator" << std::endl;
    std::cout<< " Enter seed : ";
    std::string input;
    std::getline(std::cin,input);
    wallet w;
    if(input.empty())
    {
        w=generate_new_wallet();
    }
    else{
        std::cout << "Restoring wallet from seed...\n";
        //epee::wipeable_string wipeable_seed(input);
        w = restore_wallet(input);
    }

    std::cout <<" Mnemonic Seed: " << std::endl; 
    for(const auto& word : w.seed)
    {
        std::cout<< word <<" ";
    }
    std::cout<<std::endl;
    std::string address = w.address;
    std::cout << "Wallet Address: " << address << std::endl;       
    
}

