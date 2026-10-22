import 'package:ORCHID/features/favorites/view/screens/favorites_screen.dart';
import 'package:ORCHID/features/favorites/view/widgets/web/web_favorites_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Favorites page: the desktop-first web layout
/// (>= 768px) and the untouched mobile layout must both render without overflow
/// or exceptions at every breakpoint, for an empty and a filled catalog.
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
    testWidgets('Empty favorites renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const FavoritesScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Favorites uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const FavoritesScreen());
    expect(find.byType(WebFavoritesTabs), findsOneWidget);
    expect(find.byType(WebFavoritesEmptyState), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Bouquets'), findsOneWidget);
    expect(find.text('Flowers'), findsOneWidget);
    expect(find.text('favorites'), findsOneWidget);
    expect(
      find.text('all flowers you love, saved in one place'),
      findsOneWidget,
    );
    expect(find.text('no favorite items here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Favorites tab filters change the empty-state wording', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const FavoritesScreen());

    await tester.tap(find.text('Bouquets'));
    await tester.pumpAndSettle();
    expect(find.text('no favorite Bouquets'), findsOneWidget);

    await tester.tap(find.text('Flowers'));
    await tester.pumpAndSettle();
    expect(find.text('no favorite Flowers here'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('no favorite items here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Favorites keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const FavoritesScreen());
    expect(find.byType(WebFavoritesTabs), findsNothing);
    expect(find.byType(WebFavoritesEmptyState), findsNothing);
    expect(find.text('favorites'), findsWidgets);
    expect(find.text('no favorite items here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Web favorite card never overflows with a long title', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(400, 600),
      const Center(
        child: SizedBox(
          width: 250,
          height: 347,
          child: WebFavoriteCard(
            name: 'A very long favorite flower name that should ellipsize',
            price: 1234,
            imagePath: '',
            isFavorite: true,
            onFavoriteToggle: _noop,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
