import 'package:flutter_test/flutter_test.dart';
import 'package:voix/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build app with isLoggedIn passed in
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
  });
}