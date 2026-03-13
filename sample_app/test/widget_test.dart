import 'package:flutter_test/flutter_test.dart';
import 'package:macos_sample_app/main.dart';

void main() {
  testWidgets('app shows wallet actions on the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Beldex Offline Wallet Address Generator'),
      findsOneWidget,
    );
    expect(find.text('Create New Wallet'), findsOneWidget);
    expect(find.text('Restore Wallet'), findsOneWidget);
  });

  testWidgets('app can navigate to the restore wallet screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Restore Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Seed Phrase (25 words)'), findsOneWidget);
    expect(
      find.text('Enter your 25 words separated by spaces.'),
      findsOneWidget,
    );
  });
}
