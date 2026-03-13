import 'package:flutter_test/flutter_test.dart';
import 'package:macos_sample_app/wallet_ffi.dart';

void main() {
  test('WalletPayload parses a complete combined payload', () {
    const payload =
        'address:::seed one two:::spendpub:::viewpub:::privatespend:::privateview';

    final parsed = WalletPayload.fromCombinedString(payload);

    expect(parsed.address, 'address');
    expect(parsed.seeds, 'seed one two');
    expect(parsed.spendPub, 'spendpub');
    expect(parsed.viewPub, 'viewpub');
    expect(parsed.privateSpendKey, 'privatespend');
    expect(parsed.privateViewKey, 'privateview');
    expect(parsed.isComplete, isTrue);
  });

  test('WalletPayload flags incomplete payloads', () {
    const payload = 'address:::seed one two:::spendpub';

    final parsed = WalletPayload.fromCombinedString(payload);

    expect(parsed.address, 'address');
    expect(parsed.seeds, 'seed one two');
    expect(parsed.viewPub, isEmpty);
    expect(parsed.privateSpendKey, isEmpty);
    expect(parsed.isComplete, isFalse);
  });
}
