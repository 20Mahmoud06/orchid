/// One flower line inside a custom bouquet held in the cart.
class CartItemComponent {
  const CartItemComponent({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.productId,
  });

  final String name;
  final int quantity;
  final int unitPrice;
  final String? productId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        if (productId != null) 'product_id': productId,
      };

  factory CartItemComponent.fromJson(Map<String, dynamic> json) {
    return CartItemComponent(
      name: json['name'] as String? ?? 'Flower',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toInt() ?? 0,
      productId: json['product_id'] as String?,
    );
  }
}

/// Represents a single cart item displayed on the cart screen.
class CartItem {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final int quantity;

  /// Optional note attached to this specific line (e.g. "happy birthday").
  /// The order as a whole also has its own single message and delivery.
  final String? message;

  /// Flower composition for a custom bouquet; null for plain products.
  final List<CartItemComponent>? components;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
    this.message,
    this.components,
  });

  bool get isCustomBouquet => components != null && components!.isNotEmpty;

  /// Line total for this item (unit price x quantity).
  int get total => price * quantity;

  CartItem copyWith({
    String? name,
    int? price,
    String? imagePath,
    int? quantity,
    String? message,
    List<CartItemComponent>? components,
  }) {
    return CartItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      message: message ?? this.message,
      components: components ?? this.components,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imagePath': imagePath,
        'quantity': quantity,
        if (message != null && message!.trim().isNotEmpty)
          'message': message,
        if (components != null)
          'components': components!.map((c) => c.toJson()).toList(),
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawComponents = json['components'];
    return CartItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imagePath: json['imagePath'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      message: json['message'] as String?,
      components: rawComponents is List
          ? rawComponents
              .whereType<Map>()
              .map((c) => CartItemComponent.fromJson(Map<String, dynamic>.from(c)))
              .toList()
          : null,
    );
  }
}
