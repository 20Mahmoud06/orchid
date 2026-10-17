import 'package:ORCHID/features/my_wallet/view/screens/my_wallet_screen.dart';
import 'package:ORCHID/features/my_wallet/view/widgets/web/web_wallet_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive "my wallet" page: the desktop-first web layout
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

  Future<void> pickProvider(WidgetTester tester, String name) async {
    await tester.tap(find.byType(WebWalletProviderDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
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
    testWidgets('My wallet renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const MyWalletScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('My wallet uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());
    expect(find.byType(WebWalletHeader), findsOneWidget);
    expect(find.byType(WebWalletCard), findsOneWidget);
    expect(find.byType(WebWalletProviderDropdown), findsOneWidget);
    expect(find.text('my wallet'), findsOneWidget);
    expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
    expect(find.text('Select a Provider'), findsOneWidget);
    expect(find.text('Choose your wallet provider'), findsOneWidget);
    expect(find.text('WALLET OWNER'), findsOneWidget);
    expect(find.text('WALLET ID'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('My wallet keeps the CONFIRM action visible on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());
    final confirm = tester.getRect(find.text('CONFIRM'));
    expect(confirm.top, greaterThanOrEqualTo(0));
    expect(confirm.bottom, lessThanOrEqualTo(900));
    expect(tester.takeException(), isNull);
  });

  testWidgets('My wallet keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const MyWalletScreen());
    expect(find.byType(WebWalletHeader), findsNothing);
    expect(find.byType(WebWalletCard), findsNothing);
    expect(find.byType(WebWalletProviderDropdown), findsNothing);
    expect(find.text('my wallet'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Selecting a provider updates the wallet card on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());
    await tester.tap(find.byType(WebWalletProviderDropdown));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vodafone Cash').last);
    await tester.pumpAndSettle();

    // The selected provider shows both in the card header and in the dropdown.
    expect(find.text('Vodafone Cash'), findsNWidgets(2));
    expect(find.text('Select a Provider'), findsNothing);
    expect(find.text('Choose your wallet provider'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirming with a zero balance shows the balance snackbar', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(
        'Your wallet balance is 0. Add money to your wallet to pay with it.',
      ),
      findsOneWidget,
    );
    // The wallet message uses the shared Orchid toast: 420px on desktop web.
    expect(
      _toastWidth(
        tester,
        'Your wallet balance is 0. Add money to your wallet to pay with it.',
      ),
      420,
    );
    expect(find.byType(WebWalletConfirmationDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Zero balance snackbar keeps the mobile width on phones', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const MyWalletScreen());
    await tester.tap(find.text('CONFIRM'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(
        'Your wallet balance is 0. Add money to your wallet to pay with it.',
      ),
      findsOneWidget,
    );
    // Full-width phone toast, not the 420px desktop toast.
    expect(
      _toastWidth(
        tester,
        'Your wallet balance is 0. Add money to your wallet to pay with it.',
      ),
      greaterThan(340),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet dialog stays desktop-sized with a pinned MediaQuery', (
    tester,
  ) async {
    await pumpAtPinned(tester, const Size(1440, 900), const MyWalletScreen());
    await tester.tap(find.byType(WebWalletProviderDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vodafone Cash').last);
    await tester.pumpAndSettle();

    // A wallet needs money before CONFIRM opens the confirmation dialog.
    await tester.tap(find.text('EGP ••••••••'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '500');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.byType(WebWalletConfirmationDialog), findsOneWidget);
    final content = find
        .descendant(
          of: find.byType(WebWalletConfirmationDialog),
          matching: find.byType(ConstrainedBox),
        )
        .first;
    expect(tester.getSize(content).width, lessThanOrEqualTo(440));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet balance is saved per provider', (tester) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());

    await pickProvider(tester, 'Vodafone Cash');
    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('EGP 0.00'), findsOneWidget);

    await tester.tap(find.text('EGP 0.00'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '250');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('EGP 250.00'), findsOneWidget);

    // Switching wallets must not carry Vodafone's money over.
    await pickProvider(tester, 'Orange Cash');
    expect(find.text('EGP 250.00'), findsNothing);
    expect(find.text('EGP 0.00'), findsOneWidget);

    // Returning to Vodafone restores its own balance.
    await pickProvider(tester, 'Vodafone Cash');
    expect(find.text('EGP 250.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet ID is saved per provider', (tester) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());

    await pickProvider(tester, 'Vodafone Cash');
    expect(find.text('•••• 4821'), findsOneWidget);

    await tester.tap(find.text('•••• 4821'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '11112222');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('••••2222'), findsOneWidget);

    // A different wallet keeps its own number.
    await pickProvider(tester, 'Orange Cash');
    expect(find.text('••••2222'), findsNothing);
    expect(find.text('•••• 4821'), findsOneWidget);

    await pickProvider(tester, 'Vodafone Cash');
    expect(find.text('••••2222'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet choice and balance survive a reload (browser cache)', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());

    await pickProvider(tester, 'Vodafone Cash');
    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('EGP 0.00'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '320');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.text('EGP 320.00'), findsOneWidget);

    // Simulate closing and reopening the browser: the whole tree is torn down
    // and the screen mounts fresh, reading only the cached preferences.
    await tester.pumpWidget(const SizedBox());
    await pumpAt(tester, const Size(1440, 900), const MyWalletScreen());
    await tester.pumpAndSettle();

    // The wallet picked last comes back selected together with its balance.
    expect(find.text('Vodafone Cash'), findsNWidgets(2));
    expect(find.text('Select a Provider'), findsNothing);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('EGP 320.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

/// Width of the visible toast panel.
///
/// `find.byType(SnackBar)` reports the full-viewport slot the snackbar is
/// aligned in; the visible panel is the nearest [Material] ancestor of the
/// message text (`SnackBar` wraps its Material in `SizedBox(width: ...)` when
/// `SnackBar.width` is set).
double _toastWidth(WidgetTester tester, String message) {
  final material = find
      .ancestor(of: find.text(message), matching: find.byType(Material))
      .first;
  return tester.getSize(material).width;
}
