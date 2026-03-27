Pod::Spec.new do |s|
  s.name             = 'WalletFFI'
  s.version          = '1.0.0'
  s.summary          = 'Beldex wallet native FFI library for iOS.'
  s.description      = <<-DESC
Links the generated WalletFFI.xcframework into the Flutter Runner target so
wallet_ffi.dart can resolve ffi_generate_wallet and related symbols via
DynamicLibrary.process().
                       DESC
  s.homepage         = 'https://example.com/walletffi'
  s.license          = { :type => 'Proprietary', :text => 'Internal use only.' }
  s.author           = { 'Wallet Team' => 'devnull@example.com' }
  s.source           = { :path => '.' }
  s.vendored_frameworks = 'WalletFFI.xcframework'
  s.platform         = :ios, '12.0'
  s.dependency       'Flutter'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -force_load "$(PODS_XCFRAMEWORKS_BUILD_DIR)/WalletFFI/libwallet.a"',
  }
  s.swift_version = '5.0'
end
