import 'package:ORCHID/core/app_keys.dart';
import 'package:ORCHID/core/router/app_router.dart';
import 'package:ORCHID/features/add_message/view/screens/add_message_screen.dart';
import 'package:ORCHID/features/bouquet/cubit/bouquet_cubit.dart';
import 'package:ORCHID/features/bouquet/view/screens/view_bouquet_screen.dart';
import 'package:ORCHID/features/cart/cubit/cart_cubit.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_state.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/features/choose_bouquets/models/bouquet_item.dart';
import 'package:ORCHID/features/choose_bouquets/view/screens/choose_bouquets_screen.dart';
import 'package:ORCHID/features/inspiration/models/inspiration_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

/// A message typed in the home "what are you celebrating?" flow must ride
/// along with the bouquet it was written for: it shows under the line in the
/// cart and pre-fills the message screen opened from the cart's message icon.
void main() {
  const occasionMessage = 'Will you be mine forever?';

  setUp(() async {
    await TestHarness.boot();
    CatalogCubit.instance.seed(
      const CatalogLoaded(
        flowers: [],
        bouquets: [
          BouquetItem(
            id: 'b1',
            name: 'Blush Roses',
            price: 500,
            category: 'roses',
            imagePath: '',
          ),
        ],
        popularFlowers: [],
        popularBouquets: [],
        flowerCategories: ['All flowers'],
        bouquetCategories: ['All bouquets', 'roses'],
      ),
    );
  });

  tearDown(() {
    BouquetCubit.instance.clear();
    CartCubit.instance.clearCart();
    CheckoutCubit.instance.setMessage(hasMessage: false, text: '');
    TestHarness.tearDown();
  });

  /// Boots a desktop web window (real FlutterView size) with the real router.
  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 900);
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
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          navigatorObservers: [routeObserver],
          theme: ThemeData(fontFamily: 'Inria Serif'),
          onGenerateRoute: AppRouter.generateRoute,
          home: home,
        ),
        child: null,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// Moves past a route transition without settling (cart cards shimmer while
  /// their images load, so `pumpAndSettle` would never return).
  Future<void> pumpRouteTransition(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'view bouquet moves the bouquet to the cart with the occasion message',
    (tester) async {
      CheckoutCubit.instance.setMessage(
        hasMessage: true,
        text: occasionMessage,
      );
      BouquetCubit.instance.incrementQuantity('b1');
      await pumpApp(tester, const ChooseBouquetScreen());

      await tester.tap(find.text('view bouquet (1) >'));
      await pumpRouteTransition(tester);

      final items = CartCubit.instance.items;
      expect(items, hasLength(1));
      expect(items.single.message, occasionMessage);
      // The cart line shows the message under the bouquet.
      expect(find.text(occasionMessage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Looks Good keeps the occasion message on the arrangement', (
    tester,
  ) async {
    CheckoutCubit.instance.setMessage(hasMessage: true, text: occasionMessage);
    BouquetCubit.instance.incrementQuantity('b1');
    await pumpApp(tester, const ViewBouquetScreen());

    await tester.tap(find.text('Looks Good'));
    await pumpRouteTransition(tester);

    final items = CartCubit.instance.items;
    expect(items, hasLength(1));
    expect(items.single.message, occasionMessage);
    expect(find.text(occasionMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inspiration bouquet keeps the occasion message too', (
    tester,
  ) async {
    CheckoutCubit.instance.setMessage(hasMessage: true, text: occasionMessage);
    const inspiration = InspirationItem(
      id: 'i1',
      username: 'orchid',
      imagePath: '',
      ingredients: ['roses'],
      description: 'A featured bouquet',
      flowers: [InspirationFlower(name: 'Roses', unitPrice: 400, quantity: 3)],
    );
    await pumpApp(tester, const ViewBouquetScreen(bouquet: inspiration));

    await tester.tap(find.text('Looks Good'));
    await pumpRouteTransition(tester);

    final items = CartCubit.instance.items;
    expect(items, hasLength(1));
    expect(items.single.message, occasionMessage);
    expect(find.text(occasionMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without an occasion the cart line gets no message', (
    tester,
  ) async {
    BouquetCubit.instance.incrementQuantity('b1');
    await pumpApp(tester, const ChooseBouquetScreen());

    await tester.tap(find.text('view bouquet (1) >'));
    await pumpRouteTransition(tester);

    expect(CartCubit.instance.items.single.message, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('message screen pre-fills with the cart line note', (
    tester,
  ) async {
    CartCubit.instance.addItems(const [
      CartItem(
        id: 'b1',
        name: 'Blush Roses',
        price: 500,
        imagePath: '',
        quantity: 1,
        message: occasionMessage,
      ),
    ]);
    await pumpApp(tester, const AddMessageScreen(cartItemId: 'b1'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(occasionMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
