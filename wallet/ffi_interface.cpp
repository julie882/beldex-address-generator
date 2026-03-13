#include "wallet/wallet.h"
#include <cstring>
#include <cstdlib>

#ifdef _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT __attribute__((visibility("default")))
#endif

extern "C"
{

FFI_EXPORT char* ffi_generate_wallet()
{
    wallet w = generate_new_wallet();

    // Combine all the wallet data into a single string
    // Address
    std::string combined = w.address;

    // Seed
    if (!w.seed.empty()) {
        combined += ":::";
        for (size_t i = 0; i < w.seed.size(); ++i) {
            combined += w.seed[i];
            if (i < w.seed.size() - 1) {
                combined += " ";
            }
        }
    }

    // Keys
    combined += ":::";
    combined += w.spend_pub;
    combined += ":::";
    combined += w.view_pub;
    combined += ":::";
    combined += w.private_spend_key;
    combined += ":::";
    combined += w.private_view_key;

    char* result = (char*)malloc(combined.size() + 1);
    std::strcpy(result, combined.c_str());

    return result;
}

FFI_EXPORT char* ffi_restore_wallet(const char* input_seed)
{
    wallet w = restore_wallet(input_seed);

    if(w.address.empty() || w.seed.empty() || w.spend_pub.empty() || w.view_pub.empty() || w.private_spend_key.empty() || w.private_view_key.empty())
    {
        std::cout<<"Invalid wallet: address/seed/keys are empty"<<std::endl;
        return nullptr;
    }

    // Combine all the wallet data into a single string
    // Address
    std::string combined = w.address;

    // Seed
    if (!w.seed.empty()) {
        combined += ":::";
        for (size_t i = 0; i < w.seed.size(); ++i) {
            combined += w.seed[i];
            if (i < w.seed.size() - 1) {
                combined += " ";
            }
        }
    }

    // Keys
    combined += ":::";
    combined += w.spend_pub;
    combined += ":::";
    combined += w.view_pub;
    combined += ":::";
    combined += w.private_spend_key;
    combined += ":::";
    combined += w.private_view_key;

    char* result = (char*)malloc(combined.size() + 1);
    std::strcpy(result, combined.c_str());

    return result;
}
FFI_EXPORT void ffi_free(char* ptr)
{
    free(ptr);
}

}
