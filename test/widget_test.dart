import 'package:flutter_test/flutter_test.dart';

import 'package:fitwhilework/main.dart';

void main() {
  testWidgets('App start smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitWhileWorkApp());

    // Verify that the app title is present
    expect(find.text('Fit While You Work'), findsOneWidget);
  });
}
