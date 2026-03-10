#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <cstring>
#include <string>
#include <vector>


struct wallet{
    std::string address;
    std::string view_pub;
    std::string spend_pub;
    std::string private_view_key;
    std::string private_spend_key;
    std::vector<std::string> seed;
};



wallet restore_wallet(const std::string& input_seed);

wallet generate_new_wallet();


