import 'package:ORCHID/features/delivery/view/screens/delivery_details_screen.dart';
import 'package:ORCHID/features/delivery/view/widgets/delivery_text_field.dart';
import 'package:ORCHID/features/delivery/view/widgets/web/web_delivery_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Delivery Details page: the desktop-first web layout
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
    testWidgets('Delivery Details renders without overflow (${entry.key})',
        (tester) async {
      await pumpAt(tester, entry.value, const DeliveryDetailsScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Delivery Details uses the web layout and wording on desktop',
      (tester) async {
    await pumpAt(tester, const Size(1440, 900), const DeliveryDetailsScreen());
    expect(find.byType(WebDeliveryHeader), findsOneWidget);
    expect(find.byType(WebEstimatedDeliveryCard), findsOneWidget);
    expect(find.byType(DeliveryTextField), findsNothing);
    expect(find.text('Delivery Details'), findsOneWidget);
    expect(find.text('Estimated Delivery'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Delivery Details keeps the mobile layout below the breakpoint',
      (tester) async {
    await pumpAt(tester, const Size(375, 812), const DeliveryDetailsScreen());
    expect(find.byType(WebDeliveryHeader), findsNothing);
    expect(find.byType(WebEstimatedDeliveryCard), findsNothing);
    expect(find.text('Delivery Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
