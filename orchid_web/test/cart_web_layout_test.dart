import 'package:ORCHID/features/cart/cubit/cart_cubit.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/features/cart/view/screens/cart_screen.dart';
import 'package:ORCHID/features/cart/view/widgets/web/web_cart_widgets.dart';
import 'package:ORCHID/shared/widgets/bouquet_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Cart page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
/// or exceptions at every breakpoint, for an empty and a filled cart.
void main() {
  setUp(() async {
    await TestHarness.boot();
    CartCubit.instance.clearCart();
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
    testWidgets('Empty cart renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const CartScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Empty cart uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const CartScreen());
    expect(find.byType(WebCartEmptyState), findsOneWidget);
    expect(find.text('my cart'), findsOneWidget);
    expect(find.text('your chosen items'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Start adding your favorite items!'), findsOneWidget);
    expect(find.text('CHOOSE BOUQUET'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Empty cart CHOOSE BOUQUET opens the bouquet chooser on desktop',
    (tester) async {
      await pumpAt(tester, const Size(1440, 900), const CartScreen());
      await tester.tap(find.text('CHOOSE BOUQUET'));
      await tester.pumpAndSettle();
      expect(find.byType(BouquetOptionsDialog), findsOneWidget);
      expect(find.text('Choose Bouquet'), findsOneWidget);
      expect(find.text('BUY EXISTING BOUQUET'), findsOneWidget);
      expect(find.text('CREATE MY BOUQUET'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Cart items use the web layout and wording on desktop', (
    tester,
  ) async {
    CartCubit.instance.addItems(const [
      CartItem(id: 'a', name: 'Rose', price: 100, imagePath: '', quantity: 2),
      CartItem(id: 'b', name: 'Tulip', price: 80, imagePath: '', quantity: 1),
    ]);
    addTearDown(CartCubit.instance.clearCart);

    await pumpAt(tester, const Size(1440, 900), const CartScreen());
    expect(find.byType(WebCartItemCard), findsNWidgets(2));
    expect(find.byType(WebCheckoutSummary), findsOneWidget);
    expect(find.text('you have 3 items'), findsOneWidget);
    expect(find.text('Rose'), findsOneWidget);
    expect(find.text('Tulip'), findsOneWidget);
    expect(find.text('ADD MORE ITEMS'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('CONFIRM ORDER'), findsOneWidget);
    expect(find.text('280 EGP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cart keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const CartScreen());
    expect(find.byType(WebCartEmptyState), findsNothing);
    expect(find.text('my cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Clear cart uses the web dialog on desktop', (tester) async {
    CartCubit.instance.addItems(const [
      CartItem(id: 'a', name: 'Rose', price: 100, imagePath: '', quantity: 1),
    ]);
    addTearDown(CartCubit.instance.clearCart);

    await pumpAt(tester, const Size(1440, 900), const CartScreen());
    await tester.tap(find.byIcon(Ionicons.trash).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebClearCartDialog), findsOneWidget);
    expect(find.text('Clear Cart'), findsOneWidget);
    expect(find.text('Delete All'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Delete All clears the cart and closes the dialog.
    await tester.tap(find.text('Delete All'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WebClearCartDialog), findsNothing);
    expect(find.byType(WebCartEmptyState), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Clear cart keeps the mobile dialog below the breakpoint', (
    tester,
  ) async {
    CartCubit.instance.addItems(const [
      CartItem(id: 'a', name: 'Rose', price: 100, imagePath: '', quantity: 1),
    ]);
    addTearDown(CartCubit.instance.clearCart);

    await pumpAt(tester, const Size(375, 812), const CartScreen());
    await tester.tap(find.byIcon(Ionicons.trash).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(WebClearCartDialog), findsNothing);
    expect(find.text('Clear Cart'), findsOneWidget);
    expect(find.text('Delete All'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
