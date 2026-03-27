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

struct address_info
{
    bool valid;
    std::string type;
    std::string network;
    std::string spend_public_key;
    std::string view_public_key;

    std::string payment_id; // empty if not integrated
};


wallet restore_wallet(const std::string& input_seed);

wallet generate_new_wallet();

address_info validate_address(const std::string& address);
