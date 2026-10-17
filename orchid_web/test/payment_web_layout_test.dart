import 'package:ORCHID/features/payment/view/screens/payment_screen.dart';
import 'package:ORCHID/features/payment/view/widgets/web/web_payment_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Payment page: the desktop-first web layout
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
    testWidgets('Payment renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const PaymentScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Payment uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const PaymentScreen());
    expect(find.byType(WebPaymentHeader), findsOneWidget);
    expect(find.byType(WebPaymentIllustrationCard), findsOneWidget);
    expect(find.byType(WebPaymentMethodCard), findsNWidgets(3));
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('cash'), findsOneWidget);
    expect(find.text('credit \\ debit card'), findsOneWidget);
    expect(find.text('wallet'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Payment keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const PaymentScreen());
    expect(find.byType(WebPaymentHeader), findsNothing);
    expect(find.byType(WebPaymentMethodCard), findsNothing);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirming cash opens the cash confirmation dialog on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const PaymentScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Cash Payment'), findsOneWidget);
    expect(
      find.text(
        'You will pay in cash upon delivery. Do you want to confirm this order?',
      ),
      findsOneWidget,
    );
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.byType(WebCashConfirmationDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cash confirmation dialog closes on CANCEL', (tester) async {
    await pumpAt(tester, const Size(375, 812), const PaymentScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.byType(WebCashConfirmationDialog), findsNothing);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Cash Payment'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cash dialog stays desktop-sized with a pinned MediaQuery', (
    tester,
  ) async {
    await pumpAtPinned(tester, const Size(1440, 900), const PaymentScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    // The real web build pins `MediaQuery.size`; the dialog must still pick the
    // fixed-pixel desktop variant instead of stretching to the window width.
    expect(find.byType(WebCashConfirmationDialog), findsOneWidget);
    final content = find
        .descendant(
          of: find.byType(WebCashConfirmationDialog),
          matching: find.byType(ConstrainedBox),
        )
        .first;
    expect(tester.getSize(content).width, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });
}
