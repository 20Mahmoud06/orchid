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

  /// Flowers + quantities, so "Looks Good" can rebuild this exact bouquet in
  /// the cart. Empty for the legacy/mock items.
  final List<InspirationFlower> flowers;

  const InspirationItem({
    required this.id,
    required this.username,
    required this.imagePath,
    required this.ingredients,
    required this.description,
    this.flowers = const <InspirationFlower>[],
  });
}
