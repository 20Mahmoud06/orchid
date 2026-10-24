import 'package:ORCHID/features/bouquet/cubit/bouquet_cubit.dart';
import 'package:ORCHID/features/cart/cubit/cart_cubit.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_state.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_state.dart';
import 'package:ORCHID/features/choose_flowers/models/flower_item.dart';
import 'package:ORCHID/features/choose_flowers/view/widgets/view_bouquet_bar.dart';
import 'package:ORCHID/features/inspiration/models/inspiration_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await TestHarness.boot();
    CartCubit.instance.clearCart();
    BouquetCubit.instance.clear();
    CatalogCubit.instance.seed(
      const CatalogLoaded(
        flowers: [
          FlowerItem(
            id: 'tulip-1',
            name: 'Tulip',
            price: 30,
            category: 'tulips',
            imagePath: 'assets/images/tulip.png',
          ),
          FlowerItem(
            id: 'rose-1',
            name: 'Rose',
            price: 50,
            category: 'roses',
            imagePath: 'assets/images/rose.png',
          ),
        ],
        bouquets: [],
        popularFlowers: [],
        popularBouquets: [],
        flowerCategories: ['All flowers'],
        bouquetCategories: ['All bouquets'],
      ),
    );
  });

  tearDown(() {
    CartCubit.instance.clearCart();
    BouquetCubit.instance.clear();
    CheckoutCubit.instance.beginCheckout(CheckoutSource.bouquet);
    TestHarness.tearDown();
  });

  const tenTulips = CartItem(
    id: 'custom-1',
    name: 'Custom Bouquet',
    price: 300,
    imagePath: 'assets/images/bouquet_test.png',
    components: [
      CartItemComponent(
        name: 'Tulip',
        quantity: 10,
        unitPrice: 30,
        productId: 'tulip-1',
      ),
    ],
  );

  const oneTulip = CartItem(
    id: 'custom-single',
    name: 'Custom Bouquet',
    price: 30,
    imagePath: 'assets/images/bouquet_test.png',
    components: [
      CartItemComponent(
        name: 'Tulip',
        quantity: 1,
        unitPrice: 30,
        productId: 'tulip-1',
      ),
    ],
  );

  test('a single flower uses the flower name and photo', () {
    expect(oneTulip.displayName, 'Tulip');
    expect(oneTulip.displayImagePath, 'assets/images/tulip.png');
  });

  test('a bunch of one flower kind uses the flower name plus Bouquet', () {
    expect(tenTulips.displayName, 'Tulip Bouquet');
    expect(tenTulips.displayImagePath, 'assets/images/tulip.png');
  });

  test('a mixed bouquet keeps the custom bouquet name and preview photo', () {
    const mixed = CartItem(
      id: 'custom-2',
      name: 'Custom Bouquet',
      price: 300,
      imagePath: 'assets/images/bouquet_test.png',
      components: [
        CartItemComponent(
          name: 'Tulip',
          quantity: 5,
          unitPrice: 30,
          productId: 'tulip-1',
        ),
        CartItemComponent(
          name: 'Rose',
          quantity: 3,
          unitPrice: 50,
          productId: 'rose-1',
        ),
      ],
    );
    expect(mixed.displayName, 'Custom Bouquet');
    expect(mixed.displayImagePath, 'assets/images/bouquet_test.png');
  });

  test('adding to the cart stores the bouquet identity on the line', () {
    CartCubit.instance.addItems(const [tenTulips]);

    final item = CartCubit.instance.items.single;
    expect(item.name, 'Tulip Bouquet');
    expect(item.imagePath, 'assets/images/tulip.png');
  });

  test('cart checkout stores the flower name and photo snapshots', () {
    CartCubit.instance.addItems(const [tenTulips]);
    CheckoutCubit.instance.beginCheckout(CheckoutSource.cart);

    final item = CheckoutCubit.instance.buildItems().single;
    expect(item['name_snapshot'], 'Tulip Bouquet');
    expect(item['image_snapshot'], 'assets/images/tulip.png');
    expect(CheckoutCubit.instance.checkoutItems.single.name, 'Tulip Bouquet');
    expect(
      CheckoutCubit.instance.checkoutItems.single.image,
      'assets/images/tulip.png',
    );
  });

  test('direct checkout stores the bouquet name and photo snapshots', () {
    for (var i = 0; i < 10; i++) {
      BouquetCubit.instance.incrementQuantity('tulip-1');
    }
    CheckoutCubit.instance.beginCheckout(CheckoutSource.bouquet);

    final item = CheckoutCubit.instance.buildItems().single;
    expect(item['name_snapshot'], 'Tulip Bouquet');
    expect(item['image_snapshot'], 'assets/images/tulip.png');
    expect(CheckoutCubit.instance.checkoutItems.single.name, 'Tulip Bouquet');
    expect(
      CheckoutCubit.instance.checkoutItems.single.image,
      'assets/images/tulip.png',
    );
  });

  testWidgets('the view bar says view flower only for exactly one flower', (
    tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: ViewBouquetBar(
              totalCount: 1,
              totalPrice: 30,
              isSingleFlower: true,
            ),
          ),
        ),
      ),
    );
    expect(find.text('view flower (1) >'), findsOneWidget);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(body: ViewBouquetBar(totalCount: 10, totalPrice: 300)),
        ),
      ),
    );
    expect(find.text('view bouquet (10) >'), findsOneWidget);
  });

  test('customer inspiration cards show the flower photo for one flower', () {
    const item = InspirationItem(
      id: 'i1',
      username: 'orchid',
      imagePath: 'assets/images/bouquet_test.png',
      ingredients: ['10 tulips'],
      description: 'tulips only',
      sourceOrderItemId: 'order-item-1',
      flowers: [
        InspirationFlower(
          productId: 'tulip-1',
          name: 'Tulip',
          unitPrice: 30,
          quantity: 10,
        ),
      ],
    );
    expect(item.displayImagePath, 'assets/images/tulip.png');
  });

  test('admin-added inspiration keeps its uploaded photo', () {
    const item = InspirationItem(
      id: 'i2',
      username: 'orchid',
      imagePath: 'https://example.com/tulips.jpg',
      ingredients: ['10 tulips'],
      description: 'tulips only',
      flowers: [
        InspirationFlower(
          productId: 'tulip-1',
          name: 'Tulip',
          unitPrice: 30,
          quantity: 10,
        ),
      ],
    );
    expect(item.displayImagePath, 'https://example.com/tulips.jpg');
  });

  test('component photos survive the saved-cart JSON round trip', () {
    final restored = CartItem.fromJson(tenTulips.toJson());
    expect(restored.components!.single.imagePath, isNull);
    final withImage = CartItem.fromJson(
      CartItem(
        id: tenTulips.id,
        name: tenTulips.name,
        price: tenTulips.price,
        imagePath: tenTulips.imagePath,
        components: const [
          CartItemComponent(
            name: 'Tulip',
            quantity: 10,
            unitPrice: 30,
            productId: 'tulip-1',
            imagePath: 'assets/images/tulip.png',
          ),
        ],
      ).toJson(),
    );
    expect(withImage.components!.single.imagePath, 'assets/images/tulip.png');
  });
}
