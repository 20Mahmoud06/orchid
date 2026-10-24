import '../../bouquet/utils/bouquet_naming.dart';

/// One flower inside a featured inspiration bouquet.
class InspirationFlower {
  final String? productId;
  final String name;
  final int unitPrice;
  final int quantity;

  const InspirationFlower({
    this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });
}

class InspirationItem {
  final String id;
  final String username;
  final String imagePath;
  final List<String> ingredients;
  final String description;

  /// Public URL of the creator's profile picture, when featured with one.
  final String? avatarUrl;

  /// Flowers + quantities, so "Looks Good" can rebuild this exact bouquet in
  /// the cart. Empty for the legacy/mock items.
  final List<InspirationFlower> flowers;

  /// The order item this bouquet was featured from. Null for bouquets added
  /// directly from the admin dashboard.
  final String? sourceOrderItemId;

  const InspirationItem({
    required this.id,
    required this.username,
    required this.imagePath,
    required this.ingredients,
    required this.description,
    this.avatarUrl,
    this.flowers = const <InspirationFlower>[],
    this.sourceOrderItemId,
  });

  BouquetFlowerLine? get singleFlowerLine => BouquetNaming.singleFlower(
    flowers.map(
      (flower) =>
          BouquetFlowerLine(name: flower.name, productId: flower.productId),
    ),
  );

  bool get isSingleFlowerBouquet => singleFlowerLine != null;

  String? get singleFlowerName => singleFlowerLine?.name;

  String get displayImagePath {
    if (sourceOrderItemId == null) return imagePath;
    final flower = singleFlowerLine;
    if (flower == null) return imagePath;
    return BouquetNaming.singleFlowerImage(
      productId: flower.productId,
      name: flower.name,
      fallback: imagePath,
    );
  }
}
