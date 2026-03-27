#include <iostream>
#include <string>
#include "wallet/wallet.h"

int main(int argc, char* argv[]) {

    std::cout << "1. Generate Wallet" << std::endl;
    std::cout<< "2. Enter seed : ";
    std::cout<< "3. Validate Address"<<std::endl;
    int choice;
    std::cin >> choice;
    std::cin.ignore();
    wallet w;
    if(choice == 1)
    {
        w=generate_new_wallet();
    }
    else if(choice == 2){
        std::string seed;
        std::cout << "Restoring wallet from seed...\n";
        std::getline(std::cin,seed);
        w = restore_wallet(seed);
    }
    else if(choice == 3) {
        std::string addr; 
        std::cout << "Enter Address ";
        std::cin>>addr;


        // Validate address
        resolveAddress validAddr;
        validAddr = validate_address(addr);

        std::cout << "\nEntered Address: " << addr << std::endl;
        std::cout << "Valid: " << (validAddr.valid ? "true" : "false") << std::endl;
        std::cout << "Network: " << validAddr.nettype << std::endl;
        
        std::cout << "Spend Public Key: ";
        std::cout << validAddr.spend_pub;
        
        std::cout << "View Public Key: ";
        std::cout << validAddr.view_pub;
       
    }

    std::cout <<" Mnemonic Seed: " << std::endl; 
    for(const auto& word : w.seed)
    {
        std::cout<< word <<" ";
    }
    std::cout<<std::endl;
    std::string address = w.address;
    std::cout << "Wallet Address: " << address << std::endl;       
    std::cout << "Spend Public Key: " << w.spend_pub << std::endl;
    std::cout << "View Public Key: " << w.view_pub << std::endl;
    std::cout << "Private Spend Key: " << w.private_spend_key << std::endl;
    std::cout << "Private View Key: " << w.private_view_key << std::endl;

    return 0;
}
