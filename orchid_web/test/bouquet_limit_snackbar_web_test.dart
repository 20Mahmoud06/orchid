import 'package:ORCHID/core/app_keys.dart';
import 'package:ORCHID/features/bouquet/cubit/bouquet_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_state.dart';
import 'package:ORCHID/features/choose_flowers/models/flower_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// The "up to 7 kinds / up to 15 flowers" limit messages used to render as a
/// snackbar spanning the whole browser window. On the desktop web layout they
/// must come back as the app's 420px centered toast (same as every other
/// Orchid snackbar); the mobile layout keeps the full-width default.
void main() {
  setUp(() async {
    await TestHarness.boot();
    CatalogCubit.instance.seed(
      CatalogLoaded(
        flowers: [
          for (var i = 0; i < 8; i++)
            FlowerItem(
              id: 'f$i',
              name: 'Flower $i',
              price: 100 + i,
              category: 'test',
              imagePath: '',
            ),
        ],
        bouquets: const [],
        popularFlowers: const [],
        popularBouquets: const [],
        flowerCategories: const ['All flowers', 'test'],
        bouquetCategories: const ['All bouquets'],
      ),
    );
  });

  tearDown(() {
    BouquetCubit.instance.clear();
    TestHarness.tearDown();
  });

  /// Reproduces the real web build: the phone design size is pinned on
  /// `MediaQuery` (see `main.dart`) while the underlying [FlutterView] keeps
  /// the real browser size.
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(375, 812)),
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: _buildMessengerHost,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Kind limit snackbar is deskop-toast sized on desktop web', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900));
    for (var i = 0; i < 7; i++) {
      BouquetCubit.instance.incrementQuantity('f$i');
    }
    // The 8th kind is refused with the limit message.
    BouquetCubit.instance.incrementQuantity('f7');
    await tester.pumpAndSettle();

    expect(
      find.text('you can add up to 7 different kinds of flowers'),
      findsOneWidget,
    );
    expect(
      _toastWidth(tester, 'you can add up to 7 different kinds of flowers'),
      420,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Flower limit snackbar uses the same toast size', (tester) async {
    await pumpAt(tester, const Size(1440, 900));
    // 15 flowers across the 7 allowed kinds, then one more is refused.
    const perFlower = [3, 3, 3, 2, 2, 1, 1];
    for (var i = 0; i < perFlower.length; i++) {
      for (var n = 0; n < perFlower[i]; n++) {
        BouquetCubit.instance.incrementQuantity('f$i');
      }
    }
    BouquetCubit.instance.incrementQuantity('f0');
    await tester.pumpAndSettle();

    expect(
      find.text('your bouquet can contain up to 15 flowers'),
      findsOneWidget,
    );
    expect(
      _toastWidth(tester, 'your bouquet can contain up to 15 flowers'),
      420,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Limit snackbar keeps the mobile width below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812));
    for (var i = 0; i < 7; i++) {
      BouquetCubit.instance.incrementQuantity('f$i');
    }
    BouquetCubit.instance.incrementQuantity('f7');
    await tester.pumpAndSettle();

    expect(
      find.text('you can add up to 7 different kinds of flowers'),
      findsOneWidget,
    );
    // Full-width phone toast, not the 420px desktop toast.
    expect(
      _toastWidth(tester, 'you can add up to 7 different kinds of flowers'),
      greaterThan(340),
    );
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

Widget _buildMessengerHost(BuildContext context, Widget? child) {
  return MaterialApp(
    scaffoldMessengerKey: scaffoldMessengerKey,
    theme: ThemeData(fontFamily: 'Inria Serif'),
    home: const Scaffold(body: SizedBox.expand()),
  );
}
