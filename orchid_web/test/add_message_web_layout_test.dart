import 'package:ORCHID/features/add_message/view/screens/add_message_screen.dart';
import 'package:ORCHID/features/add_message/view/widgets/add_message_header.dart';
import 'package:ORCHID/features/add_message/view/widgets/web/web_add_message_header.dart';
import 'package:ORCHID/features/add_message/view/widgets/web/web_message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Add Message page: the desktop-first web layout
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
    testWidgets('Add Message renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const AddMessageScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Add Message uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const AddMessageScreen());
    expect(find.byType(WebAddMessageHeader), findsOneWidget);
    expect(find.byType(AddMessageHeader), findsNothing);
    expect(find.text('Add a message'), findsOneWidget);
    expect(find.text('Yes, add a message.'), findsOneWidget);
    expect(find.text('No, thanks.'), findsOneWidget);
    expect(find.byType(WebMessageInputField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Add Message keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const AddMessageScreen());
    expect(find.byType(WebAddMessageHeader), findsNothing);
    expect(find.byType(AddMessageHeader), findsOneWidget);
    expect(find.text('Add a message'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
