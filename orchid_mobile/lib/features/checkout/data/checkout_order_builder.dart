import '../../bouquet/cubit/bouquet_cubit.dart';
import '../../bouquet/utils/bouquet_naming.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/models/cart_item.dart';
import '../../catalog/cubit/catalog_cubit.dart';
import '../cubit/checkout_state.dart';
import '../models/checkout_line_item.dart';

/// Builds the display lines and `order_items` rows for the current checkout
/// draft.
class CheckoutOrderBuilder {
  const CheckoutOrderBuilder._();

  /// Short text lines shown in cart-style summaries.
  static List<String> buildLines(CheckoutSource source) {
    if (source == CheckoutSource.cart) {
      return [
        for (final item in CartCubit.instance.items)
          '${item.quantity} ${item.displayName.toLowerCase()}'
              '${item.message != null && item.message!.trim().isNotEmpty ? ' — ${item.message!.trim()}' : ''}',
      ];
    }
    return BouquetCubit.instance.descriptionText.isEmpty
        ? const <String>[]
        : BouquetCubit.instance.descriptionText.split(', ').toList();
  }

  /// Structured checkout lines (photo, name, composition, line price) so the
  /// order summary can draw one card per item instead of a single card.
  static List<CheckoutLineItem> buildLineItems(CheckoutSource source) {
    if (source == CheckoutSource.cart) {
      return [
        for (final item in CartCubit.instance.items)
          CheckoutLineItem(
            name: item.displayName,
            image: item.displayImagePath,
            description: _cartItemDescription(item),
            price: item.total,
            quantity: item.quantity,
          ),
      ];
    }

    final bouquet = BouquetCubit.instance;
    final items = <CheckoutLineItem>[];

    final flowers = bouquet.selectedFlowers;
    if (flowers.isNotEmpty) {
      final flowerSubtotal = flowers.fold<int>(
        0,
        (sum, flower) => sum + flower.price * bouquet.getQuantity(flower.id),
      );
      final totalFlowerCount = flowers.fold<int>(
        0,
        (sum, flower) => sum + bouquet.getQuantity(flower.id),
      );
      final singleFlower = BouquetNaming.singleFlower(
        flowers.map(
          (flower) => BouquetFlowerLine(
            name: flower.name,
            productId: flower.id,
            imagePath: flower.imagePath,
          ),
        ),
      );
      items.add(
        CheckoutLineItem(
          name: singleFlower == null
              ? 'Custom Bouquet'
              : BouquetNaming.flowerTitle(
                  singleFlower.name,
                  quantity: totalFlowerCount,
                ),
          image: singleFlower == null
              ? flowers.first.imagePath
              : BouquetNaming.singleFlowerImage(
                  productId: singleFlower.productId,
                  name: singleFlower.name,
                  storedImage: singleFlower.imagePath,
                  fallback: flowers.first.imagePath,
                ),
          description: bouquet.descriptionText,
          price: flowerSubtotal,
          quantity: 1,
        ),
      );
    }

    for (final ready in bouquet.selectedReadyBouquets) {
      final quantity = bouquet.getQuantity(ready.id);
      items.add(
        CheckoutLineItem(
          name: ready.name,
          image: ready.imagePath,
          description: '',
          price: ready.price * quantity,
          quantity: quantity,
        ),
      );
    }

    return items;
  }

  /// Builds the `order_items` rows for the current draft.
  ///
  /// `image_snapshot` is NOT NULL in the orders schema, so the raw path is
  /// always stored: a public URL, a bundled asset path, or '' — the admin and
  /// the app both render a floral placeholder for the latter two.
  static List<Map<String, dynamic>> buildOrderItems(CheckoutSource source) {
    if (source == CheckoutSource.cart) {
      final items = <Map<String, dynamic>>[];
      for (final item in CartCubit.instance.items) {
        final message = item.message?.trim();
        final components = <String, dynamic>{
          if (message != null && message.isNotEmpty) 'message': message,
          if (item.isCustomBouquet)
            'description': item.components!
                .map((c) => '${c.quantity} ${c.name.toLowerCase()}')
                .join(', '),
          if (item.isCustomBouquet)
            'flowers': [
              for (final component in item.components!)
                {
                  'product_id': component.productId,
                  'name': component.name,
                  'quantity': component.quantity,
                  'unit_price': component.unitPrice,
                  if (component.imagePath != null &&
                      component.imagePath!.isNotEmpty)
                    'image_path': component.imagePath,
                },
            ],
        };
        items.add({
          'item_type': item.isCustomBouquet
              ? _bouquetType
              : _productType(item.id),
          'product_id': _uuidOrNull(item.id),
          'name_snapshot': item.displayName,
          'image_snapshot': item.displayImagePath,
          'price_snapshot': item.price,
          'quantity': item.quantity,
          'custom_components': components.isEmpty ? null : components,
        });
      }
      return items;
    }

    final bouquet = BouquetCubit.instance;
    final items = <Map<String, dynamic>>[];

    final flowers = bouquet.selectedFlowers;
    if (flowers.isNotEmpty) {
      final flowerSubtotal = flowers.fold<int>(
        0,
        (sum, flower) => sum + flower.price * bouquet.getQuantity(flower.id),
      );
      final totalFlowerCount = flowers.fold<int>(
        0,
        (sum, flower) => sum + bouquet.getQuantity(flower.id),
      );
      final singleFlower = BouquetNaming.singleFlower(
        flowers.map(
          (flower) => BouquetFlowerLine(
            name: flower.name,
            productId: flower.id,
            imagePath: flower.imagePath,
          ),
        ),
      );
      items.add({
        'item_type': _bouquetType,
        'product_id': null,
        'name_snapshot': singleFlower == null
            ? 'Custom Bouquet'
            : BouquetNaming.flowerTitle(
                singleFlower.name,
                quantity: totalFlowerCount,
              ),
        'image_snapshot': singleFlower == null
            ? flowers.first.imagePath
            : BouquetNaming.singleFlowerImage(
                productId: singleFlower.productId,
                name: singleFlower.name,
                storedImage: singleFlower.imagePath,
                fallback: flowers.first.imagePath,
              ),
        'price_snapshot': flowerSubtotal,
        'quantity': 1,
        'custom_components': {
          'description': bouquet.descriptionText,
          'flowers': [
            for (final flower in flowers)
              {
                'product_id': flower.id,
                'name': flower.name,
                'quantity': bouquet.getQuantity(flower.id),
                'unit_price': flower.price,
                if (flower.imagePath.isNotEmpty) 'image_path': flower.imagePath,
              },
          ],
        },
      });
    }

    for (final ready in bouquet.selectedReadyBouquets) {
      items.add({
        'item_type': _bouquetType,
        'product_id': ready.id,
        'name_snapshot': ready.name,
        'image_snapshot': ready.imagePath,
        'price_snapshot': ready.price,
        'quantity': bouquet.getQuantity(ready.id),
        'custom_components': null,
      });
    }

    return items;
  }

  static String _cartItemDescription(CartItem item) {
    final message = item.message?.trim();
    if (item.isCustomBouquet) {
      final composition = item.components!
          .map((c) => '${c.quantity} ${c.name.toLowerCase()}')
          .join(', ');
      return (message != null && message.isNotEmpty)
          ? '$composition — $message'
          : composition;
    }
    return message ?? '';
  }

  /// Cart item ids only become `order_items.product_id` when they really
  /// are a product UUID — custom bouquet entries use local ids.
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static String? _uuidOrNull(String id) =>
      _uuidPattern.hasMatch(id) ? id : null;

  /// `order_items.item_type` shares the `products.type` vocabulary.
  static const String _bouquetType = 'ready_bouquet';
  static const String _flowerType = 'flower';

  /// Plain cart products keep their catalog type when known, falling back to
  /// `flower` — both are valid values either way.
  static String _productType(String productId) {
    final isBouquet = CatalogCubit.instance.bouquets.any(
      (bouquet) => bouquet.id == productId,
    );
    return isBouquet ? _bouquetType : _flowerType;
  }
}
