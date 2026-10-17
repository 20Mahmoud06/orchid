import 'package:ORCHID/features/auth/view/screens/login_screen.dart';
import 'package:ORCHID/features/auth/view/screens/splash_screen.dart';
import 'package:ORCHID/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  testWidgets('App launches on the splash screen', (WidgetTester tester) async {
    TestHarness.useDesignSize(tester);

    await tester.pumpWidget(const OrchidApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('ORCHID'), findsOneWidget);
    expect(find.text('flower shop'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Drain the splash's three second hand-off timer, otherwise the test ends
    // with a pending timer, which `testWidgets` reports as a failure.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Splash hands over to login when nobody is signed in',
      (WidgetTester tester) async {
    TestHarness.useDesignSize(tester);

    await tester.pumpWidget(const OrchidApp());
    await tester.pump();

    // The splash waits three seconds before resolving the first route.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login screen fits the design width', (WidgetTester tester) async {
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