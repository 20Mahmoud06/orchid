import 'package:ORCHID/features/home/view/screens/home_screen.dart';
import 'package:ORCHID/features/home/view/widgets/web/web_home_widgets.dart';
import 'package:ORCHID/features/profile/view/screens/main_navigation_screen.dart';
import 'package:ORCHID/shared/widgets/custom_bottom_navigation_bar.dart';
import 'package:ORCHID/shared/widgets/web_top_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive storefront Home page: the desktop-first web layout
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
    // Let the catalog future resolve into its (failure) state so no timers are
    // left pending, and so the layout is exercised after the first rebuild.
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
    testWidgets('Home renders without overflow (${entry.key})', (tester) async {
      await pumpAt(tester, entry.value, const HomeScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Home uses the desktop storefront wording on wide screens', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const HomeScreen());
    expect(find.text('Shop by occasion'), findsOneWidget);
    expect(find.text('Popular flowers'), findsOneWidget);
    expect(find.text('Build a bouquet that feels like you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const HomeScreen());
    expect(find.text('Build your own\nbouquet'), findsOneWidget);
    expect(find.text('Shop by occasion'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shell shows the desktop header and hides the bottom bar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MainNavigationScreen());
    expect(find.byType(WebTopNavBar), findsOneWidget);
    expect(find.byType(CustomBottomNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shell shows the bottom bar on mobile', (tester) async {
    await pumpAt(tester, const Size(375, 812), const MainNavigationScreen());
    expect(find.byType(CustomBottomNavigationBar), findsOneWidget);
    expect(find.byType(WebTopNavBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Web product card never overflows with a long title', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(400, 600),
      const Center(
        child: SizedBox(
          width: 300,
          height: 336,
          child: WebProductCard(
            imageUrl: 'https://example.invalid/flower.jpg',
            title: 'A very long bouquet name that should be truncated safely',
            price: '1234 EGP',
            isFavorite: true,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
