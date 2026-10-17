import '../../../../core/supabase/supabase.dart';
import '../../domain/models/order_model.dart';

class OrdersRepository {
  Future<List<Order>> getAllOrders() async {
    final rows = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);

    final profiles = await _fetchProfiles(rows);
    return rows.map((row) => _mapOrder(row, profiles)).toList();
  }

  Future<Order?> getOrderByCode(String orderCode) async {
    final row = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('order_code', orderCode)
        .maybeSingle();
    if (row == null) return null;

    final profiles = await _fetchProfiles([row]);
    return _mapOrder(row, profiles);
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    await supabase
        .from('orders')
        .update({
          'status': status.dbValue,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  /// profiles has no FK link from orders, so customer names are resolved in a
  /// second query and mapped client-side.
  Future<Map<String, Map<String, dynamic>>> _fetchProfiles(
    List<Map<String, dynamic>> rows,
  ) async {
    final userIds = rows
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (userIds.isEmpty) return const {};

    final profiles = await supabase
        .from('profiles')
        .select('id, username, phone')
        .inFilter('id', userIds);

    return {
      for (final profile in profiles)
        if (profile['id'] is String)
          profile['id'] as String: Map<String, dynamic>.from(profile),
    };
  }

  Order _mapOrder(
    Map<String, dynamic> row,
    Map<String, Map<String, dynamic>> profiles,
  ) {
    final items = (row['order_items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(OrderItem.fromRow)
            .toList() ??
        <OrderItem>[];

    final profile = profiles[row['user_id'] as String?];
    return Order.fromRow(
      row,
      items: items,
      customerName: profile?['username'] as String?,
      customerPhone: profile?['phone'] as String?,
    );
  }
}
