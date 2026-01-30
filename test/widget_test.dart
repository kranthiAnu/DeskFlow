import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitwhilework/main.dart';

void main() {
  testWidgets('App start smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitWhileWorkApp());
    await tester.pumpAndSettle(); // Wait for async init in HomeScreen

    // Verify that the app title is present (AppBar title)
    expect(find.text('DeskFlow'), findsOneWidget);
  });
}
