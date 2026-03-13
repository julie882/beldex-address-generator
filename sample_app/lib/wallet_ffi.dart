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

class WalletPayload {
  const WalletPayload({
    required this.address,
    required this.seeds,
    required this.spendPub,
    required this.viewPub,
    required this.privateSpendKey,
    required this.privateViewKey,
  });

  final String address;
  final String seeds;
  final String spendPub;
  final String viewPub;
  final String privateSpendKey;
  final String privateViewKey;

  static WalletPayload fromCombinedString(String payload) {
    final parts = payload.split(':::');

    return WalletPayload(
      address: parts.isNotEmpty ? parts[0] : '',
      seeds: parts.length > 1 ? parts[1] : '',
      spendPub: parts.length > 2 ? parts[2] : '',
      viewPub: parts.length > 3 ? parts[3] : '',
      privateSpendKey: parts.length > 4 ? parts[4] : '',
      privateViewKey: parts.length > 5 ? parts[5] : '',
    );
  }

  bool get isComplete =>
      address.isNotEmpty &&
      seeds.isNotEmpty &&
      spendPub.isNotEmpty &&
      viewPub.isNotEmpty &&
      privateSpendKey.isNotEmpty &&
      privateViewKey.isNotEmpty;

  Map<String, String> toMap() {
    return {
      'address': address,
      'seeds': seeds,
      'spend_pub': spendPub,
      'view_pub': viewPub,
      'private_spend_key': privateSpendKey,
      'private_view_key': privateViewKey,
    };
  }
}

class WalletFfi {
  static final WalletFfi _instance = WalletFfi._internal();
  factory WalletFfi() => _instance;

  late DynamicLibrary _lib;
  late GenerateWalletDart _generateWallet;
  late RestoreWalletDart _restoreWallet;
  late FreeStringDart _freeString;

  WalletFfi._internal() {
    _lib = _openLibrary();

    // Lookup functions
    _generateWallet =
        _lib
            .lookup<NativeFunction<GenerateWalletC>>('ffi_generate_wallet')
            .asFunction();

    _restoreWallet =
        _lib
            .lookup<NativeFunction<RestoreWalletC>>('ffi_restore_wallet')
            .asFunction();

    _freeString =
        _lib.lookup<NativeFunction<FreeStringC>>('ffi_free').asFunction();
  }

  DynamicLibrary _openLibrary() {
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }

    if (Platform.isMacOS) {
      return DynamicLibrary.open(
        '/Users/apple/Documents/sowjanya/wallet/build/wallet/libwallet.dylib',
      );
    }

    if (Platform.isAndroid) {
      return DynamicLibrary.open('libwallet.so');
    }

    if (Platform.isWindows) {
      return DynamicLibrary.open('libwallet.dll');
    }

    // Fallback to process for other platforms (e.g., Linux)
    return DynamicLibrary.process();
  }

  /// Generates a new wallet returning `{ 'address': String, 'seeds': String }`
  Map<String, String> generateNewWallet() {
    final Pointer<Utf8> resultPtr = _generateWallet();
    if (resultPtr == nullptr) {
      throw Exception('Failed to generate wallet via FFI');
    }

    final String resultString = resultPtr.toDartString();

    // Free the C string memory to avoid leaks
    _freeString(resultPtr);

    return WalletPayload.fromCombinedString(resultString).toMap();
  }

  /// restoring a wallet returning `{ 'address': String, 'seeds': String }`
  Map<String, String> restoreWallet(String input_seed) {
    final inputSeedPtr = input_seed.toNativeUtf8();

    try {
      final Pointer<Utf8> resultPtr = _restoreWallet(inputSeedPtr);
      if (resultPtr == nullptr) {
        throw Exception('Failed to restore wallet via FFI');
      }

      final String resultString = resultPtr.toDartString();

      // Free the C string memory to avoid leaks
      _freeString(resultPtr);

      return WalletPayload.fromCombinedString(resultString).toMap();
    } finally {
      malloc.free(inputSeedPtr);
    }
  }
}
