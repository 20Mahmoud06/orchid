import 'package:ORCHID/features/profile/view/screens/contact_us_screen.dart';
import 'package:ORCHID/features/profile/view/widgets/web/web_contact_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Contact Us page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
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

  for (final entry in breakpoints.entries) {
    testWidgets('Contact Us renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const ContactUsScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Contact Us uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ContactUsScreen());
    expect(find.byType(WebContactSection), findsOneWidget);
    expect(find.text('contact us'), findsOneWidget);
    expect(find.text('HOW CAN WE HELP YOU ?'), findsOneWidget);
    expect(find.text('Call Us'), findsOneWidget);
    expect(find.text('Chat With Us'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Our Location'), findsOneWidget);
    expect(find.text('Follow Us'), findsOneWidget);
    expect(find.text('stay in bloom with ORCHID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Contact Us keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const ContactUsScreen());
    expect(find.byType(WebContactSection), findsNothing);
    expect(find.text('Call Us'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
