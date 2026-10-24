import '../../catalog/cubit/catalog_cubit.dart';

class BouquetFlowerLine {
  const BouquetFlowerLine({required this.name, this.productId, this.imagePath});

  final String name;
  final String? productId;
  final String? imagePath;
}

abstract final class BouquetNaming {
  static String normalize(String name) => name.trim().toLowerCase();

  static bool isSameFlower(BouquetFlowerLine a, BouquetFlowerLine b) {
    final aName = normalize(a.name);
    final bName = normalize(b.name);
    if (aName.isNotEmpty && bName.isNotEmpty) return aName == bName;
    return a.productId != null && a.productId == b.productId;
  }

  static BouquetFlowerLine? singleFlower(Iterable<BouquetFlowerLine> flowers) {
    final list = flowers.toList(growable: false);
    if (list.isEmpty) return null;
    final first = list.first;
    for (var i = 1; i < list.length; i++) {
      if (!isSameFlower(first, list[i])) return null;
    }
    return first;
  }

  static String flowerTitle(String flowerName, {int quantity = 1}) {
    final title = _titleCase(flowerName);
    if (title.isEmpty) return 'Custom Bouquet';
    return quantity > 1 ? '$title Bouquet' : title;
  }

  static String? catalogFlowerImage(String? productId, String name) {
    final flowers = CatalogCubit.instance.flowers;
    for (final flower in flowers) {
      if (productId != null &&
          flower.id == productId &&
          flower.imagePath.isNotEmpty) {
        return flower.imagePath;
      }
    }
    final normalized = normalize(name);
    if (normalized.isEmpty) return null;
    for (final flower in flowers) {
      if (normalize(flower.name) == normalized && flower.imagePath.isNotEmpty) {
        return flower.imagePath;
      }
    }
    return null;
  }

  static String singleFlowerImage({
    required String? productId,
    required String name,
    String? storedImage,
    required String fallback,
  }) {
    if (storedImage != null && storedImage.trim().isNotEmpty) {
      return storedImage;
    }
    final catalogImage = catalogFlowerImage(productId, name);
    if (catalogImage != null && catalogImage.isNotEmpty) {
      return catalogImage;
    }
    return fallback;
  }

  static String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
