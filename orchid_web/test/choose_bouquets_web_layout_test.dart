import 'package:ORCHID/features/choose_bouquets/models/bouquet_item.dart';
import 'package:ORCHID/features/choose_bouquets/view/screens/choose_bouquets_screen.dart';
import 'package:ORCHID/features/choose_bouquets/view/widgets/web/web_choose_bouquets_widgets.dart';
import 'package:ORCHID/features/choose_flowers/view/widgets/web/web_choose_flowers_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// Verifies the responsive Choose Bouquets page: the desktop-first web layout
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
    testWidgets('Choose Bouquets renders without overflow (${entry.key})', (
      tester,
    ) async {
      await pumpAt(tester, entry.value, const ChooseBouquetScreen());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Choose Bouquets uses the web layout and wording on desktop', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1440, 900), const ChooseBouquetScreen());
    expect(find.byType(WebFlowerSearchBar), findsOneWidget);
    expect(find.byType(WebFlowerCategoryTabs), findsOneWidget);
    expect(find.text('choose bouquets'), findsOneWidget);
    expect(find.text('Search for bouquets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Choose Bouquets keeps the mobile layout below the breakpoint', (
    tester,
  ) async {
    await pumpAt(tester, const Size(375, 812), const ChooseBouquetScreen());
    expect(find.byType(WebFlowerSearchBar), findsNothing);
    expect(find.byType(WebFlowerCategoryTabs), findsNothing);
    expect(find.text('choose bouquets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Web bouquet card never overflows with a long title', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(400, 600),
      Center(
        child: SizedBox(
          width: 240,
          height: 300,
          child: WebBouquetGridCard(
            bouquet: const BouquetItem(
              id: 'b1',
              name: 'A very long bouquet name that should ellipsize nicely',
              price: 1234,
              category: 'roses',
              imagePath: '',
            ),
            isFavorite: false,
            quantity: 3,
            onFavoriteToggle: _noop,
            onIncrement: _noop,
            onDecrement: _noop,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
