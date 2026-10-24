import '../../../../core/supabase/supabase.dart';
import '../../domain/models/order_model.dart';

class OrdersRepository {
  /// Returns orders inside the supplied date boundaries.
  ///
  /// [startUtc] is inclusive and [endUtc] is exclusive. Pass `null` for either
  /// boundary to leave that side unbounded (for example, All Time).
  Future<List<Order>> getAllOrders({
    DateTime? startUtc,
    DateTime? endUtc,
  }) async {
    var query = supabase.from('orders').select('*, order_items(*)');
    if (startUtc != null) {
      query = query.gte('created_at', startUtc.toIso8601String());
    }
    if (endUtc != null) {
      query = query.lt('created_at', endUtc.toIso8601String());
    }

    final rows = await query.order('created_at', ascending: false);
    final profiles = await _fetchProfiles(rows);
    return rows.map((row) => _mapOrder(row, profiles)).toList();
  }

  /// Returns a page of orders for the dashboard without joining order items.
  ///
  /// Date boundaries are passed as UTC [startUtc] (inclusive) and [endUtc]
  /// (exclusive) so the filtering happens in Supabase, not in Dart.
  Future<List<Order>> getRecentOrders({
    DateTime? startUtc,
    DateTime? endUtc,
    int limit = 5,
    int offset = 0,
  }) async {
    assert(limit > 0, 'limit must be greater than zero');
    assert(offset >= 0, 'offset must not be negative');

    var query = supabase
        .from('orders')
        .select(
          'id,order_code,status,delivery_date,order_time,delivery_address,'
          'delivery_fee,service_fee,total,payment_method,user_id,message,'
          'additional_notes,created_at,updated_at',
        );
    if (startUtc != null) {
      query = query.gte('created_at', startUtc.toIso8601String());
    }
    if (endUtc != null) {
      query = query.lt('created_at', endUtc.toIso8601String());
    }

    final rows = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
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
    final items =
        (row['order_items'] as List?)
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
