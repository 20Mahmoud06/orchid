import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase.dart';
import '../../domain/models/product_model.dart';

class ProductsRepository {
  static const String _bucket = 'product-images';

  Future<List<Product>> getAllProducts() async {
    final rows = await supabase
        .from('products')
        .select('*, categories(name)')
        .order('created_at', ascending: false);
    return rows.map(Product.fromRow).toList();
  }

  Future<Product?> getProductById(String id) async {
    final row = await supabase
        .from('products')
        .select('*, categories(name)')
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : Product.fromRow(row);
  }

  Future<Product> createProduct({
    required String name,
    required double price,
    required ProductType type,
    required String? categoryId,
    required bool isActive,
    required String imagePath,
  }) async {
    final row = await supabase
        .from('products')
        .insert({
          'name': name,
          'price': price,
          'type': type.dbValue,
          'category_id': categoryId,
          'is_active': isActive,
          'image_path': imagePath,
        })
        .select('*, categories(name)')
        .single();
    return Product.fromRow(row);
  }

  Future<Product> updateProduct({
    required String id,
    required String name,
    required double price,
    required ProductType type,
    required String? categoryId,
    required bool isActive,
    required String imagePath,
  }) async {
    final row = await supabase
        .from('products')
        .update({
          'name': name,
          'price': price,
          'type': type.dbValue,
          'category_id': categoryId,
          'is_active': isActive,
          'image_path': imagePath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select('*, categories(name)')
        .single();
    return Product.fromRow(row);
  }

  Future<void> deleteProduct(String id) async {
    await supabase.from('products').delete().eq('id', id);
  }

  /// Uploads product image bytes and returns the stored path.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final extension = _extensionOf(filename);
    final path =
        'products/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _mimeTypeOf(extension),
            upsert: false,
          ),
        );
    return path;
  }

  /// Best-effort cleanup of a replaced/removed image.
  Future<void> deleteProductImage(String path) async {
    if (path.isEmpty || path.startsWith('http')) return;
    try {
      await supabase.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Orphaned files are harmless; never fail a product action on cleanup.
    }
  }

  static String _extensionOf(String filename) {
    final dot = filename.lastIndexOf('.');
    final extension =
        dot == -1 ? '' : filename.substring(dot + 1).toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => extension,
      _ => 'jpg',
    };
  }

  static String _mimeTypeOf(String extension) => switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };
}
