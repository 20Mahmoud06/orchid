import 'package:ORCHID/core/constants/app_assets.dart';
import 'package:ORCHID/core/router/app_router.dart';
import 'package:ORCHID/features/bouquet/cubit/bouquet_cubit.dart';
import 'package:ORCHID/features/bouquet/view/screens/view_bouquet_screen.dart';
import 'package:ORCHID/features/cart/cubit/cart_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_state.dart';
import 'package:ORCHID/features/choose_flowers/models/flower_item.dart';
import 'package:ORCHID/features/inspiration/models/inspiration_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive View Bouquet page: the desktop-first web layout
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
    testWidgets('View Bouquet renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const ViewBouquetScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('View Bouquet uses the web layout on desktop', (tester) async {
    await pumpAt(tester, const Size(1440, 900), const ViewBouquetScreen());
    expect(find.text('your bouquet'), findsOneWidget);
    expect(find.text('Edit Bouquet'), findsOneWidget);
    expect(find.text('Looks Good'), findsOneWidget);

    // On desktop the two actions sit side by side on the same row.
    final edit = tester.getCenter(find.text('Edit Bouquet'));
    final looks = tester.getCenter(find.text('Looks Good'));
    expect(edit.dy, closeTo(looks.dy, 1));
    expect(edit.dx, lessThan(looks.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('View Bouquet stacks the actions on mobile', (tester) async {
    await pumpAt(tester, const Size(375, 812), const ViewBouquetScreen());
    final edit = tester.getCenter(find.text('Edit Bouquet'));
    final looks = tester.getCenter(find.text('Looks Good'));
    expect(edit.dy, lessThan(looks.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inspiration bouquet shows a single Looks Good action', (
    tester,
  ) async {
    const item = InspirationItem(
      id: 'i1',
      username: 'orchid',
      imagePath: '',
      ingredients: ['3 roses', '2 tulips'],
      description: 'spring mix',
    );
    await pumpAt(
      tester,
      const Size(1440, 900),
      const ViewBouquetScreen(bouquet: item),
    );
    expect(find.text('your bouquet'), findsOneWidget);
    expect(find.text('Looks Good'), findsOneWidget);
    expect(find.text('Edit Bouquet'), findsNothing);
    expect(find.text('3 roses'), findsOneWidget);
    expect(find.text('2 tulips'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  /// Seeds two flowers so the builder can hold a custom arrangement.
  void seedCatalog() {
    CatalogCubit.instance.seed(
      CatalogLoaded(
        flowers: const [
          FlowerItem(
            id: 'f1',
            name: 'Rose',
            price: 50,
            category: 'roses',
            imagePath: 'assets/images/rose.png',
          ),
          FlowerItem(
            id: 'f2',
            name: 'Tulip',
            price: 40,
            category: 'tulips',
            imagePath: 'assets/images/tulip.png',
          ),
        ],
        bouquets: const [],
        popularFlowers: const [],
        popularBouquets: const [],
        flowerCategories: const ['All flowers'],
        bouquetCategories: const ['All bouquets'],
      ),
    );
  }

  /// Like [pumpAt] but with the app router so "Looks Good" can push the cart.
  Future<void> pumpRoutedAt(
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
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          theme: ThemeData(fontFamily: 'Inria Serif'),
          onGenerateRoute: AppRouter.generateRoute,
          home: child,
        ),
        child: child,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('Mixed custom bouquet keeps the bouquet preview in the cart', (
    tester,
  ) async {
    seedCatalog();
    BouquetCubit.instance.incrementQuantity('f1');
    BouquetCubit.instance.incrementQuantity('f2');
    addTearDown(() {
      BouquetCubit.instance.clear();
      CartCubit.instance.clearCart();
    });

    await pumpRoutedAt(
      tester,
      const Size(1440, 900),
      const ViewBouquetScreen(),
    );
    // The screen itself shows the bouquet preview for a mixed arrangement.
    await tester.tap(find.text('Looks Good'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(CartCubit.instance.items, hasLength(1));
    expect(CartCubit.instance.items.first.imagePath, AppAssets.bouquetTest);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Single-flower bouquet keeps its own photo in the cart', (
    tester,
  ) async {
    seedCatalog();
    BouquetCubit.instance.incrementQuantity('f1');
    addTearDown(() {
      BouquetCubit.instance.clear();
      CartCubit.instance.clearCart();
    });

    await pumpRoutedAt(
      tester,
      const Size(1440, 900),
      const ViewBouquetScreen(),
    );
    expect(find.text('View Your Flower'), findsOneWidget);
    await tester.tap(find.text('Looks Good'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(CartCubit.instance.items, hasLength(1));
    expect(CartCubit.instance.items.first.imagePath, 'assets/images/rose.png');
    expect(tester.takeException(), isNull);
  });
}
