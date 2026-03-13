# iOS FFI integration

This Flutter app can use the native wallet code on iOS, but iOS does not load a
standalone macOS-style `.dylib` from disk the way the macOS sample does.

For iOS and the iOS simulator, the correct packaging is an `xcframework`
containing a static library built for:

- `iphoneos` (`arm64`)
- `iphonesimulator` (`arm64` and/or `x86_64`)

The Dart side is already set up to use `DynamicLibrary.process()` on iOS in
`sample_app/lib/wallet_ffi.dart`, which means the exported C symbols just need
to be linked into the Runner app.

## Build the xcframework

1. Build Boost separately for both SDKs.
2. Export these environment variables:

```bash
export IOS_BOOST_SIM_ROOT=/absolute/path/to/boost-ios-simulator-prefix
export IOS_BOOST_DEVICE_ROOT=/absolute/path/to/boost-ios-device-prefix
```

3. Run:

```bash
./build_ios_xcframework.sh
```

This creates:

```text
sample_app/ios/WalletFFI.xcframework
```

## Connect it to Flutter Runner

1. Open `sample_app/ios/Runner.xcworkspace` in Xcode.
2. Drag `WalletFFI.xcframework` into the `Runner` project.
3. In the `Runner` target, add it under `Frameworks, Libraries, and Embedded Content`.
4. For a static xcframework, use `Do Not Embed`.
5. Build the `Runner` scheme for an iOS simulator.

## Important note about Boost

The current C++ wallet target links Boost libraries. That means the iOS build
will not succeed until Boost is also available for both iPhoneOS and
iPhoneSimulator.

## Runtime behavior

On iOS, Dart should keep using:

```dart
DynamicLibrary.process()
```

That is the correct lookup mechanism once the wallet symbols are linked into the
app binary through the xcframework.
