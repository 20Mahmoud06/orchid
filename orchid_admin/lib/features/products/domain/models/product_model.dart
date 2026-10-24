import 'package:supabase_flutter/supabase_flutter.dart';

enum ProductType {
  flower('Flower'),
  readyBouquet('Ready Bouquet');

  const ProductType(this.label);

  final String label;

  String get dbValue => switch (this) {
    ProductType.flower => 'flower',
    ProductType.readyBouquet => 'ready_bouquet',
  };

  static ProductType fromDb(String? value) =>
      value == 'ready_bouquet' ? ProductType.readyBouquet : ProductType.flower;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.isActive,
    required this.imagePath,
    required this.createdAt,
    this.categoryId,
    this.categoryName,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double price;
  final ProductType type;
  final bool isActive;
  final String imagePath;
  final DateTime createdAt;
  final String? categoryId;
  final String? categoryName;
  final DateTime? updatedAt;

  String get imageUrl => productImageUrl(imagePath);

  factory Product.fromRow(Map<String, dynamic> row) {
    final category = row['categories'];
    return Product(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      price: (row['price'] as num?)?.toDouble() ?? 0,
      type: ProductType.fromDb(row['type'] as String?),
      isActive: row['is_active'] as bool? ?? false,
      imagePath: row['image_path'] as String? ?? '',
      categoryId: row['category_id'] as String?,
      categoryName: category is Map ? category['name'] as String? : null,
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? ''),
    );
  }
}

String productImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return Supabase.instance.client.storage
      .from('product-images')
      .getPublicUrl(path);
}
