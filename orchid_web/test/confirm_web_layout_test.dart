import 'package:ORCHID/features/confirm/view/screens/confirm_screen.dart';
import 'package:ORCHID/features/confirm/view/widgets/web/web_confirm_widgets.dart';
import 'package:ORCHID/shared/widgets/skeleton_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Confirm page: the desktop-first web layout
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
    testWidgets('Confirm renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const ConfirmScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Confirm uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ConfirmScreen());
    expect(find.byType(WebConfirmHeader), findsOneWidget);
    expect(find.byType(WebConfirmOrderCodeCard), findsOneWidget);
    expect(find.text('ORDER CONFIRMED !'), findsOneWidget);
    expect(find.text('ORDER CODE'), findsOneWidget);
    expect(find.text('Thank you for choosing ORCHID'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirm keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const ConfirmScreen());
    expect(find.byType(WebConfirmHeader), findsNothing);
    expect(find.byType(WebConfirmOrderCodeCard), findsNothing);
    expect(find.text('ORDER CONFIRMED !'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirm shows the photo and the text side by side on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ConfirmScreen());
    final imageBox = tester.getRect(find.byType(SkeletonImage));
    final titleBox = tester.getRect(find.text('ORDER CONFIRMED !'));
    expect(imageBox.right, lessThan(titleBox.left));
    expect(tester.takeException(), isNull);
  });
}
