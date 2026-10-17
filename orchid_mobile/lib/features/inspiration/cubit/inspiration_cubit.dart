import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspiration_item.dart';
import 'inspiration_state.dart';

/// Featured custom bouquets, curated by the admin dashboard and shown on the
/// mobile Inspiration tab. Read-only for shoppers; the table is written from
/// the admin app.
class InspirationCubit extends Cubit<InspirationState> {
  InspirationCubit() : super(const InspirationInitial());

  static final InspirationCubit instance = InspirationCubit();

  static const String _bucket = 'product-images';

  /// How many featured bouquets the tab shows (the newest ones).
  static const int maxItems = 5;

  List<InspirationItem> get items => state is InspirationLoaded
      ? (state as InspirationLoaded).items
      : const <InspirationItem>[];

  bool get isLoading => state is InspirationLoading;

  bool get isLoaded => state is InspirationLoaded;

  Object? get error =>
      state is InspirationFailure ? (state as InspirationFailure).error : null;

  /// Fetches the featured bouquets. Safe to call from every screen: the first
  /// call fetches, later calls are no-ops unless [force] re-fetches.
  Future<void> load({bool force = false}) async {
    if (state is InspirationLoading || (state is InspirationLoaded && !force)) {
      return;
    }
    await Future<void>.microtask(() {});
    if (state is InspirationLoading || (state is InspirationLoaded && !force)) {
      return;
    }

    emit(const InspirationLoading());
    try {
      final client = Supabase.instance.client;
      final ownSourceIds = await _ownOrderItemIds();
      List<Map<String, dynamic>> rows;
      try {
        rows = await _fetchRows(client, includeProfileImage: true);
      } catch (_) {
        // The `profile_image` column may not exist until the matching
        // migration is applied; fall back so the tab keeps working.
        rows = await _fetchRows(client, includeProfileImage: false);
      }

      // "what others are creating" — never feature the signed-in user's own
      // bouquets back to them.
      final featured = <InspirationItem>[];
      for (final row in rows) {
        if (featured.length >= maxItems) break;
        final source = row['source_order_item_id'];
        if (source is String && ownSourceIds.contains(source)) continue;
        featured.add(_map(row));
      }
      emit(InspirationLoaded(featured));
    } catch (e) {
      emit(InspirationFailure(e));
    }
  }

  /// Fetches the newest featured bouquets. [includeProfileImage] controls
  /// whether the creator-avatar column is requested (it may not exist yet on
  /// a database where the migration has not been applied).
  Future<List<Map<String, dynamic>>> _fetchRows(
    SupabaseClient client, {
    required bool includeProfileImage,
  }) {
    final columns = StringBuffer(
      'id, display_name, image_snapshot, description, ingredients, '
      'source_order_item_id, created_at',
    );
    if (includeProfileImage) {
      columns.write(', profile_image');
    }
    return client
        .from('inspiration_items')
        .select(columns.toString())
        .order('created_at', ascending: false)
        .limit(50);
  }

  /// Ids of `order_items` belonging to the current user, so their own orders
  /// are excluded from the inspiration list. Falls back to an empty set (show
  /// everything) when the lookup fails.
  Future<Set<String>> _ownOrderItemIds() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return const <String>{};
    try {
      final rows = await client
          .from('orders')
          .select('order_items(id)')
          .eq('user_id', user.id);
      final ids = <String>{};
      for (final row in rows) {
        final items = row['order_items'];
        if (items is! List) continue;
        for (final item in items) {
          if (item is Map && item['id'] is String) {
            ids.add(item['id'] as String);
          }
        }
      }
      return ids;
    } catch (_) {
      return const <String>{};
    }
  }

  InspirationItem _map(Map<String, dynamic> row) {
    final flowers = <InspirationFlower>[];
    final lines = <String>[];
    final raw = row['ingredients'];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map) continue;
        final name = (entry['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        final quantity = (entry['quantity'] as num?)?.toInt() ?? 1;
        flowers.add(
          InspirationFlower(
            productId: entry['product_id'] as String?,
            name: name,
            unitPrice: ((entry['unit_price'] as num?) ?? 0).round(),
            quantity: quantity,
          ),
        );
        lines.add('$quantity ${name.toLowerCase()}');
      }
    }

    final displayName = (row['display_name'] as String? ?? '').trim();
    final profileImage = (row['profile_image'] as String? ?? '').trim();
    return InspirationItem(
      id: row['id'] as String? ?? '',
      username: displayName.isEmpty ? 'orchid' : displayName,
      imagePath: _imageUrl(row['image_snapshot'] as String? ?? ''),
      ingredients: lines,
      description: row['description'] as String? ?? '',
      avatarUrl: profileImage.isEmpty ? null : _profileImageUrl(profileImage),
      flowers: flowers,
    );
  }

  String _imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http') || path.startsWith('assets/')) return path;
    return Supabase.instance.client.storage.from(_bucket).getPublicUrl(path);
  }

  String _profileImageUrl(String path) {
    if (path.startsWith('http') || path.startsWith('assets/')) return path;
    return Supabase.instance.client.storage
        .from('profile-images')
        .getPublicUrl(path);
  }
}
