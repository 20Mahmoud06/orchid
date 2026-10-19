import '../../../../core/supabase/supabase.dart';
import '../../domain/models/inspiration_model.dart';

class InspirationRepository {
  /// How many featured bouquets the mobile tab displays.
  static const int maxFeatured = 5;

  /// Bouquets currently featured on the mobile Inspiration tab.
  Future<List<InspirationItem>> getFeatured() async {
    final rows = await supabase
        .from('inspiration_items')
        .select('*')
        .order('created_at', ascending: false);
    return rows.map(InspirationItem.fromRow).toList();
  }

  /// Recent real custom bouquets (order items with a flower composition),
  /// resolved with the customer name, newest order first.
  Future<List<InspirationCandidate>> getCandidates() async {
    final orders = await supabase
        .from('orders')
        .select(
          'id, user_id, created_at, '
          'order_items(id, name_snapshot, image_snapshot, custom_components)',
        )
        .order('created_at', ascending: false)
        .limit(60);

    final profiles = await _fetchProfiles(orders);
    final candidates = <InspirationCandidate>[];

    for (final order in orders) {
      final items = order['order_items'];
      if (items is! List) continue;
      final createdAt =
          DateTime.tryParse(order['created_at'] as String? ?? '');
      final profile = profiles[order['user_id'] as String?];
      final customerName = profile?['username'] as String?;
      final profileImage = profile?['profile_image'] as String?;

      for (final item in items) {
        if (item is! Map) continue;
        final components = item['custom_components'];
        if (components is! Map) continue;
        final description = (components['description'] as String?)?.trim();
        final rawFlowers = components['flowers'];
        if ((description == null || description.isEmpty) &&
            (rawFlowers is! List || rawFlowers.isEmpty)) {
          continue;
        }

        candidates.add(
          InspirationCandidate(
            orderItemId: item['id'] as String? ?? '',
            customerName: customerName,
            imageUrl: item['image_snapshot'] as String?,
            description: description,
            orderCreatedAt: createdAt,
            profileImage: profileImage,
            ingredients: rawFlowers is List
                ? rawFlowers
                    .whereType<Map>()
                    .map((e) =>
                        InspirationIngredient.fromJson(Map<String, dynamic>.from(e)))
                    .toList()
                : <InspirationIngredient>[],
          ),
        );
      }
    }

    return candidates;
  }

  Future<void> addFromCandidate(
    InspirationCandidate candidate, {
    String? displayName,
  }) async {
    await supabase.from('inspiration_items').insert({
      'display_name': displayName ?? candidate.customerName,
      'image_snapshot': candidate.imageUrl,
      'description': candidate.description,
      'ingredients': [
        for (final ingredient in candidate.ingredients) ingredient.toJson(),
      ],
      'source_order_item_id': candidate.orderItemId,
      if (candidate.profileImage != null && candidate.profileImage!.isNotEmpty)
        'profile_image': candidate.profileImage,
    });
  }

  Future<void> remove(String id) async {
    await supabase.from('inspiration_items').delete().eq('id', id);
  }

  Future<Map<String, Map<String, dynamic>>> _fetchProfiles(
    List<Map<String, dynamic>> orders,
  ) async {
    final userIds = orders
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (userIds.isEmpty) return const {};

    final profiles = await supabase
        .from('profiles')
        .select('id, username, profile_image')
        .inFilter('id', userIds);

    return {
      for (final profile in profiles)
        if (profile['id'] is String) profile['id'] as String: profile,
    };
  }
}
