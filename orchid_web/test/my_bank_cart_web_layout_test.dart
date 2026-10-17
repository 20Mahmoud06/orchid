import 'package:ORCHID/features/my_bank_cart/view/screens/my_bank_cart_screen.dart';
import 'package:ORCHID/features/my_bank_cart/view/widgets/web/web_bank_card_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive "my bank card" page: the desktop-first web layout
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

  /// Like [pumpAt], but reproduces the real web build, which pins
  /// `MediaQuery.size` to the phone design size (see `main.dart`). Dialogs have
  /// no `LayoutBuilder`, so they must still pick the desktop variant off the
  /// real viewport.
  Future<void> pumpAtPinned(
    WidgetTester tester,
    Size size,
    Widget child,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(375, 812)),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            theme: ThemeData(fontFamily: 'Inria Serif'),
            home: child,
          ),
          child: child,
        ),
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
    testWidgets('My bank card renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const MyBankCartScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('My bank card uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyBankCartScreen());
    expect(find.byType(WebBankCardHeader), findsOneWidget);
    expect(find.byType(WebBankCardInfo), findsOneWidget);
    expect(find.byType(WebBankCardForm), findsOneWidget);
    expect(find.byType(WebBankCardPreview), findsOneWidget);
    expect(find.text('my bank card'), findsOneWidget);
    expect(find.text('Add your bank card'), findsOneWidget);
    expect(
      find.text('Securely save a card for faster payments.'),
      findsOneWidget,
    );
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('My bank card keeps the CONFIRM action visible on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyBankCartScreen());
    // The card preview must not balloon (landscape fallback) and push CONFIRM
    // off-screen; the action has to sit inside the viewport.
    final preview = tester.getSize(find.byType(WebBankCardPreview));
    expect(preview.height, lessThan(300));
    final confirm = tester.getRect(find.text('CONFIRM'));
    expect(confirm.top, greaterThanOrEqualTo(0));
    expect(confirm.bottom, lessThanOrEqualTo(900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('My bank card keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const MyBankCartScreen());
    expect(find.byType(WebBankCardHeader), findsNothing);
    expect(find.byType(WebBankCardForm), findsNothing);
    expect(find.byType(WebBankCardPreview), findsNothing);
    expect(find.text('my bank card'), findsOneWidget);
    expect(find.text('Add your bank card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Valid card CONFIRM opens the web confirmation dialog', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyBankCartScreen());

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), '4111111111111111');
    await tester.enterText(fields.at(1), '1230');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), 'JOHN DOE');
    await tester.pump();

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.byType(WebBankCardConfirmationDialog), findsOneWidget);
    expect(find.text('Confirm Card Payment'), findsOneWidget);
    expect(
      find.text(
        'You will be charged on the provided credit card upon delivery. Do you want to confirm this order?',
      ),
      findsOneWidget,
    );
    expect(find.text('CANCEL'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.byType(WebBankCardConfirmationDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Incomplete card does not open the confirmation dialog', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyBankCartScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();
    expect(find.byType(WebBankCardConfirmationDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Card dialog stays desktop-sized with a pinned MediaQuery', (
    tester,
  ) async {
    await pumpAtPinned(tester, const Size(1440, 900), const MyBankCartScreen());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '4111111111111111');
    await tester.enterText(fields.at(1), '1230');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), 'JOHN DOE');
    await tester.pump();

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.byType(WebBankCardConfirmationDialog), findsOneWidget);
    final content = find
        .descendant(
          of: find.byType(WebBankCardConfirmationDialog),
          matching: find.byType(ConstrainedBox),
        )
        .first;
    expect(tester.getSize(content).width, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });
}
