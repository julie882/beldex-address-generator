import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI signatures
typedef GenerateWalletC = Pointer<Utf8> Function();
typedef GenerateWalletDart = Pointer<Utf8> Function();

typedef RestoreWalletC = Pointer<Utf8> Function(Pointer<Utf8> input_seed);
typedef RestoreWalletDart = Pointer<Utf8> Function(Pointer<Utf8> input_seed);

typedef FreeStringC = Void Function(Pointer<Utf8> ptr);
typedef FreeStringDart = void Function(Pointer<Utf8> ptr);

class WalletFfi {
  static final WalletFfi _instance = WalletFfi._internal();
  factory WalletFfi() => _instance;

  late DynamicLibrary _lib;
  late GenerateWalletDart _generateWallet;
  late RestoreWalletDart _restoreWallet;
  late FreeStringDart _freeString;

  WalletFfi._internal() {
    // Load the dynamic library
    if (Platform.isMacOS || Platform.isIOS) {
      // In a real app this would typically be loaded via process or app bundle frameworks wrapper, 
      // but if we link it locally we can point to it directly:
      // Since this is a sample app running locally, we can point to the absolute path 
      // or copy the dylib to the build folder.
      _lib = DynamicLibrary.open('/Users/apple/Documents/sowjanya/wallet/build/wallet/libwallet.dylib');
    } else if (Platform.isAndroid || Platform.isLinux) {
      _lib = DynamicLibrary.process(); // Or specific .so path
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('wallet.dll');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Lookup functions
    _generateWallet = _lib
        .lookup<NativeFunction<GenerateWalletC>>('ffi_generate_wallet')
        .asFunction();

    _restoreWallet = _lib
        .lookup<NativeFunction<RestoreWalletC>>('ffi_restore_wallet')
        .asFunction();

    _freeString = _lib
        .lookup<NativeFunction<FreeStringC>>('ffi_free')
        .asFunction();
  }

  /// Generates a new wallet returning `{ 'address': String, 'seeds': String }`
  Map<String, String> generateNewWallet() {
    final Pointer<Utf8> resultPtr = _generateWallet();
    if (resultPtr == nullptr) {
      throw Exception('Failed to generate wallet via FFI');
    }

    final String resultString = resultPtr.toDartString();

    print('resultString: $resultString');
    
    // Free the C string memory to avoid leaks
    _freeString(resultPtr);

    // Parse the result
    final parts = resultString.split(':::');
    
    String address = parts.isNotEmpty ? parts[0] : '';
    String seeds = parts.length > 1 ? parts[1] : '';

    return {
      'address': address,
      'seeds': seeds,
    };
  }

   /// restoring a wallet returning `{ 'address': String, 'seeds': String }`
   Map<String, String> restoreWallet(String input_seed) {
    final Pointer<Utf8> resultPtr = _restoreWallet(input_seed.toNativeUtf8());
    if (resultPtr == nullptr) {
      throw Exception('Failed to restore wallet via FFI');
    }

    final String resultString = resultPtr.toDartString();

    print('resultString: $resultString');
    
    // Free the C string memory to avoid leaks
    _freeString(resultPtr);

    // Parse the result
    final parts = resultString.split(':::');
    
    String address = parts.isNotEmpty ? parts[0] : '';
    String finalSeeds = parts.length > 1 ? parts[1] : '';

    return {
      'address': address,
      'seeds': finalSeeds,
    };
  }
}
