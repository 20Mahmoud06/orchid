import 'dart:typed_data';

import '../../domain/models/product_model.dart';

class ProductFormData {
  const ProductFormData({
    required this.name,
    required this.price,
    required this.type,
    required this.categoryId,
    required this.isActive,
    required this.existingImagePath,
    this.pickedImageBytes,
    this.pickedImageName,
  });

  final String name;
  final double price;
  final ProductType type;
  final String? categoryId;
  final bool isActive;
  final String existingImagePath;
  final Uint8List? pickedImageBytes;
  final String? pickedImageName;

  bool get hasNewImage => pickedImageBytes != null;
}
