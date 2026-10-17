/// Represents a single flower available for bouquet selection.
class BouquetItem {
  final String id;
  final String name;
  final int price;
  final String category;
  final String imagePath;

  const BouquetItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
  });
}
