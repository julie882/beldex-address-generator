#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstring>
#include <string>
#include <vector>


struct wallet{
    //account_keys keys;
    std::string address;
    std::vector<std::string> seed;
};



wallet restore_wallet(const std::string& input_seed);

wallet generate_new_wallet();


