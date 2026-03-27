#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstring>
#include <string>
#include <vector>

#pragma once

#ifdef _WIN32
  #ifdef WALLET_BUILD
    #define WALLET_API __declspec(dllexport)
  #else
    #define WALLET_API __declspec(dllimport)
  #endif
#else
  #define WALLET_API
#endif


struct wallet{
    std::string address;
    std::string view_pub;
    std::string spend_pub;
    std::string private_view_key;
    std::string private_spend_key;
    std::vector<std::string> seed;
};

struct resolveAddress{
    bool valid;
    std::string nettype;
    std::string view_pub;
    std::string spend_pub;
};


wallet restore_wallet(const std::string& input_seed);

wallet generate_new_wallet();

resolveAddress validate_address(const std::string& addr);

