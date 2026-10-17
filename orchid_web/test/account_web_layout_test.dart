import 'package:ORCHID/features/account/view/screens/about_screen.dart';
import 'package:ORCHID/features/account/view/screens/privacy_policy_screen.dart';
import 'package:ORCHID/features/account/view/screens/terms_conditions_screen.dart';
import 'package:ORCHID/features/account/view/widgets/web/web_account_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive static account pages (About App, Privacy Policy,
/// Terms & Conditions): the desktop-first web layout (>= 768px) and the
/// untouched mobile layout must both render without overflow or exceptions at
/// every breakpoint.
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
    await tester.pump(const Duration(milliseconds: 200));
  }

  const breakpoints = <String, Size>{
    'mobile': Size(375, 812),
    'tablet': Size(768, 900),
    'laptop': Size(1024, 768),
    'wide': Size(1280, 800),
    'desktop': Size(1440, 900),
    'fullHd': Size(1920, 1080),
    'short': Size(1024, 520),
  };

  final screens = <String, Widget>{
    'About': const AboutScreen(),
    'Privacy': const PrivacyPolicyScreen(),
    'Terms': const TermsConditionsScreen(),
  };

  for (final screen in screens.entries) {
    for (final entry in breakpoints.entries) {
      testWidgets('${screen.key} renders without overflow (${entry.key})',
          (tester) async {
        await pumpAt(tester, entry.value, screen.value);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('About uses the web layout and wording on desktop',
      (tester) async {
    await pumpAt(tester, const Size(1440, 900), const AboutScreen());
    expect(find.byType(AccountWebScaffold), findsOneWidget);
    expect(find.text('about app'), findsOneWidget);
    expect(find.text('App Name'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Last Updated'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
    expect(find.text('More than flowers'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Privacy uses the web layout and wording on desktop',
      (tester) async {
    await pumpAt(tester, const Size(1440, 900), const PrivacyPolicyScreen());
    expect(find.byType(AccountWebScaffold), findsOneWidget);
    expect(find.text('privacy policy'), findsOneWidget);
    expect(find.text('Your Privacy Matters'), findsOneWidget);
    expect(find.text('Information We Collect'), findsOneWidget);
    expect(find.text('How We Use Your Data'), findsOneWidget);
    expect(find.text('Your Security'), findsOneWidget);
    expect(find.text('Thank you for trusting ORCHID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Terms uses the web layout and wording on desktop',
      (tester) async {
    await pumpAt(tester, const Size(1440, 900), const TermsConditionsScreen());
    expect(find.byType(AccountWebScaffold), findsOneWidget);
    expect(find.text('terms & conditions'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Use of the App'), findsOneWidget);
    expect(find.text('Orders & Payments'), findsOneWidget);
    expect(find.text('Limitation of Liability'), findsOneWidget);
    expect(find.text('Thank you for being with us'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Account pages keep the mobile layout below the breakpoint',
      (tester) async {
    await pumpAt(tester, const Size(375, 812), const AboutScreen());
    expect(find.byType(AccountWebScaffold), findsNothing);
    expect(find.text('about app'), findsOneWidget);

    await pumpAt(tester, const Size(375, 812), const PrivacyPolicyScreen());
    expect(find.byType(AccountWebScaffold), findsNothing);

    await pumpAt(tester, const Size(375, 812), const TermsConditionsScreen());
    expect(find.byType(AccountWebScaffold), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
