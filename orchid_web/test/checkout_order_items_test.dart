import 'package:ORCHID/features/bouquet/cubit/bouquet_cubit.dart';
import 'package:ORCHID/features/cart/cubit/cart_cubit.dart';
import 'package:ORCHID/features/cart/models/cart_item.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_cubit.dart';
import 'package:ORCHID/features/catalog/cubit/catalog_state.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_cubit.dart';
import 'package:ORCHID/features/checkout/cubit/checkout_state.dart';
import 'package:ORCHID/features/choose_bouquets/models/bouquet_item.dart';
import 'package:ORCHID/features/choose_flowers/models/flower_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_harness.dart';

void main() {
  setUp(() async {
    await TestHarness.boot();
    CartCubit.instance.clearCart();
    BouquetCubit.instance.clear();
  });

  tearDown(() {
    TestHarness.tearDown();
    CartCubit.instance.clearCart();
    BouquetCubit.instance.clear();
    CheckoutCubit.instance.beginCheckout(CheckoutSource.bouquet);
  });

  testWidgets('cart checkout stores a non-null image snapshot for every line', (
    tester,
  ) async {
    CartCubit.instance.addItems([
      const CartItem(
        id: 'custom-1',
        name: 'Custom Bouquet',
        price: 60,
        imagePath: 'assets/images/bouquet_test.png',
        components: [
          CartItemComponent(
            name: 'rose',
            quantity: 2,
            unitPrice: 30,
            productId: 'rose-1',
          ),
        ],
      ),
      const CartItem(
        id: '11111111-1111-1111-1111-111111111111',
        name: 'Lily',
        price: 25,
        imagePath: '',
      ),
    ]);
    CheckoutCubit.instance.beginCheckout(CheckoutSource.cart);

    final items = CheckoutCubit.instance.buildItems();

    expect(items, hasLength(2));
    expect(items[0]['image_snapshot'], 'assets/images/bouquet_test.png');
    expect(items[1]['image_snapshot'], '');
  });

  testWidgets(
    'direct checkout stores a non-null image snapshot for bouquet lines',
    (tester) async {
      CatalogCubit.instance.seed(
        const CatalogLoaded(
          flowers: [
            FlowerItem(
              id: '11111111-1111-1111-1111-111111111111',
              name: 'Rose',
              price: 30,
              category: 'roses',
              imagePath: '',
            ),
          ],
          bouquets: [
            BouquetItem(
              id: '22222222-2222-2222-2222-222222222222',
              name: 'Sunset',
              price: 120,
              category: 'bouquets',
              imagePath: '',
            ),
          ],
          popularFlowers: [],
          popularBouquets: [],
          flowerCategories: ['All flowers'],
          bouquetCategories: ['All bouquets'],
        ),
      );
      BouquetCubit.instance.incrementQuantity(
        '11111111-1111-1111-1111-111111111111',
      );
      BouquetCubit.instance.incrementQuantity(
        '22222222-2222-2222-2222-222222222222',
      );
      CheckoutCubit.instance.beginCheckout(CheckoutSource.bouquet);

      final items = CheckoutCubit.instance.buildItems();

      expect(items, hasLength(2));
      expect(items[0]['name_snapshot'], 'Rose');
      expect(items[0]['image_snapshot'], '');
      expect(items[1]['name_snapshot'], 'Sunset');
      expect(items[1]['image_snapshot'], '');
    },
  );
}
