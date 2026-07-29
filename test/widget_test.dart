// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expence_track/app.dart';
import 'package:expence_track/features/auth/provider/auth_provider.dart';
import 'package:expence_track/features/expense/provider/expense_provider.dart';

void main() {
  testWidgets('Expense Tracker app loads successfully', (WidgetTester tester) async {
    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );

    // Wait for auth check
    await tester.pump();

    // Verify splash screen shows while loading
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
