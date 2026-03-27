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

1. Build Boost for both iOS targets:

```bash
cd /Users/apple/Documents/sowjanya/wallet
./build_boost_ios.sh
```

This produces:

```text
build-boost-ios/iphoneos
build-boost-ios/iphonesimulator
```

2. If you want to use custom Boost prefixes instead, export these environment variables:

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

The Flutter app now includes:

- `sample_app/ios/Podfile`
- `sample_app/ios/WalletFFI.podspec`

After building the xcframework, run:

```bash
cd sample_app/ios
pod install
```

Then open `sample_app/ios/Runner.xcworkspace` in Xcode or run the app with
Flutter. CocoaPods will link `WalletFFI.xcframework` into the Runner target, so
no manual drag-and-drop step is required.

## Important note about Boost

The iOS flow needs static Boost libraries for both `iphoneos` and
`iphonesimulator`. The repo now includes `build_boost_ios.sh`, which builds the
minimal set required by the wallet:

- `system`
- `thread`
- `serialization`
- `atomic`
- `date_time`

## Runtime behavior

On iOS, Dart should keep using:

```dart
DynamicLibrary.process()
```

That is the correct lookup mechanism once the wallet symbols are linked into the
app binary through the xcframework.
