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

    std::string combined = w.address;
    if (!w.seed.empty()) {
        combined += ":::";
        for (size_t i = 0; i < w.seed.size(); ++i) {
            combined += w.seed[i];
            if (i < w.seed.size() - 1) {
                combined += " ";
            }
        }
    }

    std::cout << "combined: " << combined << std::endl;
    char* result = (char*)malloc(combined.size() + 1);
    std::strcpy(result, combined.c_str());

    return result;
}

FFI_EXPORT char* ffi_restore_wallet(const char* input_seed)
{
    wallet w = restore_wallet(input_seed);

    std::string combined = w.address;
    if (!w.seed.empty()) {
        combined += ":::";
        for (size_t i = 0; i < w.seed.size(); ++i) {
            combined += w.seed[i];
            if (i < w.seed.size() - 1) {
                combined += " ";
            }
        }
    }

    std::cout << "combined: " << combined << std::endl;
    char* result = (char*)malloc(combined.size() + 1);
    std::strcpy(result, combined.c_str());

    return result;
}
FFI_EXPORT void ffi_free(char* ptr)
{
    free(ptr);
}

}