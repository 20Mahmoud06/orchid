import 'package:ORCHID/features/auth/view/screens/login_screen.dart';
import 'package:ORCHID/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  testWidgets('App launches and lands on login when nobody is signed in', (
    WidgetTester tester,
  ) async {
    TestHarness.useDesignSize(tester);

    await tester.pumpWidget(const OrchidApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login screen fits the design width', (
    WidgetTester tester,
  ) async {
    TestHarness.useDesignSize(tester);

    await tester.pumpWidget(
      MaterialApp(
        // Same family the app boots with, so the text measures like it does on
        // a device rather than like the 1em-per-glyph test font.
        theme: ThemeData(fontFamily: 'Inria Serif'),
        home: LoginScreen(
          onNavigateToSignup: () {},
          onNavigateToForgotPassword: () {},
        ),
      ),
    );
    await tester.pump();

    // The "remember me" row is the tightest one on the screen.
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('forgot password?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
