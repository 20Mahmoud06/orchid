import 'package:ORCHID/features/auth/view/screens/forgot_password_screen.dart';
import 'package:ORCHID/features/auth/view/screens/login_screen.dart';
import 'package:ORCHID/features/auth/view/screens/sign_up_screen.dart';
import 'package:ORCHID/features/profile/view/screens/complete_profile_screen.dart';
import 'package:ORCHID/features/profile/view/widgets/web/web_profile_avatars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive authentication pages: the desktop-first web layout
/// (>= 768px) and the mobile layout (< 768px) must both render without overflow
/// or exceptions at every breakpoint.
void main() {
  setUp(() async {
    await TestHarness.boot();
  });

  tearDown(TestHarness.tearDown);

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          theme: ThemeData(fontFamily: 'Inria Serif'),
          home: child,
        ),
        child: child,
      ),
    );
    await tester.pump();
  }

  const breakpoints = <String, Size>{
    'mobile': Size(375, 812),
    'tablet': Size(820, 1180),
    'laptop': Size(1280, 800),
    'desktop': Size(1600, 1000),
    'short': Size(1024, 520),
  };

  for (final entry in breakpoints.entries) {
    testWidgets('Login renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(
        tester,
        entry.value,
        LoginScreen(
          onNavigateToSignup: () {},
          onNavigateToForgotPassword: () {},
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Sign-up renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(
        tester,
        entry.value,
        SignUpScreen(onNavigateToLogin: () {}, onBackPressed: () {}),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Forgot-password renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(
        tester,
        entry.value,
        ForgotPasswordScreen(onBackPressed: () {}),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Complete profile renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const CompleteProfileScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Login uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1600, 1000),
      LoginScreen(onNavigateToSignup: () {}, onNavigateToForgotPassword: () {}),
    );
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('forgot password?'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sign-up uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1600, 1000),
      SignUpScreen(onNavigateToLogin: () {}, onBackPressed: () {}),
    );
    expect(find.text('SIGNUP'), findsOneWidget);
    expect(find.text('signup'), findsOneWidget);
    expect(find.text('login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Forgot-password uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1600, 1000),
      ForgotPasswordScreen(onBackPressed: () {}),
    );
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Complete profile uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1600, 1000), const CompleteProfileScreen());
    expect(find.text('Complete Your Account'), findsWidgets);
    expect(find.text('Complete Account'), findsOneWidget);
    expect(
      find.text('add your details to personalize your experience'),
      findsOneWidget,
    );
    expect(find.byType(WebCompleteProfileAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
