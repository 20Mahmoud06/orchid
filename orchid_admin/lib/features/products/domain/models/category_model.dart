class Category {
  const Category({required this.id, required this.name, this.createdAt});

  final String id;
  final String name;
  final DateTime? createdAt;

  factory Category.fromRow(Map<String, dynamic> row) => Category(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
      );
}
