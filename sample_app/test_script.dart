import 'package:flutter_driver/flutter_driver.dart';

void main() async {
  final driver = await FlutterDriver.connect();
  // Wait for the UI to settle
  await Future.delayed(Duration(seconds: 2));
  
  // Try to find the Create Wallet button from the main app and tap it
  // This depends on the widget having a key, but since it doesn't, we can try by text
  final findCreateWalletButton = find.text('Create Wallet');
  
  print('Tapping Create Wallet...');
  await driver.tap(findCreateWalletButton);
  
  await Future.delayed(Duration(seconds: 5));
  driver.close();
}
