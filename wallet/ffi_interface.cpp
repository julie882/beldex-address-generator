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

    char* result = (char*)malloc(w.address.size() + 1);
    std::strcpy(result, w.address.c_str());

    return result;
}

FFI_EXPORT void ffi_free(char* ptr)
{
    free(ptr);
}

}