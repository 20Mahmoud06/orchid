import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_order.dart';
import 'orders_state.dart';

/// Live order history for the signed-in customer, backed by the same
/// `orders` / `order_items` tables the admin dashboard manages.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersInitial());

  static final OrdersCubit instance = OrdersCubit();

  List<CustomerOrder> get orders =>
      state is OrdersLoaded ? (state as OrdersLoaded).orders : const <CustomerOrder>[];

  bool get isLoading => state is OrdersLoading;

  bool get isLoaded => state is OrdersLoaded;

  Object? get error => state is OrdersFailure ? (state as OrdersFailure).error : null;

  /// Fetches this customer's orders, newest first. Safe to call from every
  /// screen: the first call fetches, later calls are no-ops unless [force]
  /// re-fetches.
  Future<void> load({bool force = false}) async {
    if (state is OrdersLoading || (state is OrdersLoaded && !force)) return;
    // Deferred so calls made from `initState` never emit in the middle of a
    // build.
    await Future<void>.microtask(() {});
    if (state is OrdersLoading || (state is OrdersLoaded && !force)) return;

    emit(const OrdersLoading());
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(const OrdersLoaded(<CustomerOrder>[]));
        return;
      }

      final rows = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      emit(
        OrdersLoaded(
          rows
              .map((row) {
                final items = (row['order_items'] as List?)
                        ?.whereType<Map<String, dynamic>>()
                        .map(CustomerOrderItem.fromRow)
                        .toList() ??
                    <CustomerOrderItem>[];
                return CustomerOrder.fromRow(row, items: items);
              })
              .where((order) => order.id.isNotEmpty)
              .toList(),
        ),
      );
    } catch (e) {
      emit(OrdersFailure(e));
    }
  }

  /// Marks a single order as canceled. The row is kept (never deleted) so the
  /// admin dashboard still sees it, just with a CANCELED status.
  Future<void> cancelOrder(CustomerOrder order) async {
    final client = Supabase.instance.client;
    await client
        .from('orders')
        .update({
          'status': 'CANCELED',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', order.id);
    emit(
      OrdersLoaded([
        for (final o in orders)
          if (o.id == order.id) o.copyWith(status: 'CANCELED') else o,
      ]),
    );
  }

  /// Cancels every order in the list, keeping all rows in the dashboard.
  Future<void> cancelAll() async {
    if (orders.isEmpty) return;
    final client = Supabase.instance.client;
    final ids = orders.map((order) => order.id).toList();
    await client
        .from('orders')
        .update({
          'status': 'CANCELED',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .inFilter('id', ids);
    emit(
      OrdersLoaded([
        for (final order in orders) order.copyWith(status: 'CANCELED'),
      ]),
    );
  }
}
