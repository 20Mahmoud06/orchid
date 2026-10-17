class InspirationIngredient {
  const InspirationIngredient({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.productId,
  });

  final String? productId;
  final String name;
  final int quantity;
  final int unitPrice;

  factory InspirationIngredient.fromJson(Map<String, dynamic> json) =>
      InspirationIngredient(
        productId: json['product_id'] as String?,
        name: json['name'] as String? ?? 'Flower',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: ((json['unit_price'] as num?) ?? 0).round(),
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
      };
}

/// A bouquet featured on the mobile Inspiration tab.
class InspirationItem {
  const InspirationItem({
    required this.id,
    required this.ingredients,
    required this.createdAt,
    this.displayName,
    this.imageUrl,
    this.description,
    this.sourceOrderItemId,
  });

  final String id;
  final List<InspirationIngredient> ingredients;
  final DateTime createdAt;
  final String? displayName;
  final String? imageUrl;
  final String? description;
  final String? sourceOrderItemId;

  double get total => ingredients.fold(
        0,
        (sum, item) => sum + item.unitPrice * item.quantity,
      );

  factory InspirationItem.fromRow(Map<String, dynamic> row) {
    final raw = row['ingredients'];
    return InspirationItem(
      id: row['id'] as String? ?? '',
      displayName: row['display_name'] as String?,
      imageUrl: row['image_snapshot'] as String?,
      description: row['description'] as String?,
      sourceOrderItemId: row['source_order_item_id'] as String?,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      ingredients: raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  InspirationIngredient.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <InspirationIngredient>[],
    );
  }
}

/// A real custom bouquet from a customer order, eligible to be featured.
class InspirationCandidate {
  const InspirationCandidate({
    required this.orderItemId,
    required this.ingredients,
    this.customerName,
    this.imageUrl,
    this.description,
    this.orderCreatedAt,
  });

  final String orderItemId;
  final List<InspirationIngredient> ingredients;
  final String? customerName;
  final String? imageUrl;
  final String? description;
  final DateTime? orderCreatedAt;

  double get total => ingredients.fold(
        0,
        (sum, item) => sum + item.unitPrice * item.quantity,
      );
}
