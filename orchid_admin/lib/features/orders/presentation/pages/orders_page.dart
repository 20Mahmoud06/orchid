import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/time/date_range.dart';
import '../../data/repositories/orders_repository.dart';
import '../../domain/models/order_model.dart';
import '../widgets/order_details_panel.dart';
import '../widgets/orders_empty_details.dart';
import '../widgets/orders_error_state.dart';
import '../widgets/orders_list_card.dart';
import '../widgets/orders_page_header.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrdersRepository _repository = OrdersRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Order> _orders = <Order>[];
  Order? _selectedOrder;
  OrderStatus? _statusFilter;
  DateRange _dateRange = DateRange.allTime;
  bool _isLoading = true;
  String? _loadError;
  RealtimeChannel? _channel;
  Timer? _debounce;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _subscribeToRealtime();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    final requestId = ++_loadRequestId;

    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final orders = await _repository.getAllOrders(
        startUtc: _dateRange.startUtc,
        endUtc: _dateRange.endUtc,
      );
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
        _loadError = null;
        _selectedOrder = _findSelectedOrder(orders);
      });
    } catch (error) {
      if (!mounted || requestId != _loadRequestId) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  void _selectDateRange(DateRange range) {
    if (range == _dateRange) return;
    setState(() => _dateRange = range);
    unawaited(_load());
  }

  Order? _findSelectedOrder(List<Order> orders) {
    final selectedId = _selectedOrder?.id;
    if (selectedId != null) {
      for (final order in orders) {
        if (order.id == selectedId) return order;
      }
    }
    return orders.isNotEmpty ? orders.first : null;
  }

  /// Reloads whenever an admin (or the mobile app) changes an order.
  void _subscribeToRealtime() {
    _channel = supabase
        .channel('admin-orders-list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (_) {
            _debounce?.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 600),
              () => _load(silent: true),
            );
          },
        )
        .subscribe();
  }

  Future<void> _changeStatus(Order order, OrderStatus status) async {
    if (order.status == status) return;

    try {
      await _repository.updateOrderStatus(order.id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${order.orderCode} marked ${status.label}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _load(silent: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _selectOrder(Order order) {
    setState(() => _selectedOrder = order);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 1100;
    final isMobile = width < 720;

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrdersPageHeader(
                dateRange: _dateRange,
                onRangeChanged: _selectDateRange,
                isLoading: _isLoading,
                onRefresh: () => _load(),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                OrdersErrorState(message: _loadError!, onRetry: () => _load())
              else if (isNarrow)
                Column(
                  children: [
                    _buildOrdersList(),
                    const SizedBox(height: 20),
                    _buildDetails(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildOrdersList()),
                    const SizedBox(width: 20),
                    Expanded(flex: 6, child: _buildDetails()),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return OrdersListCard(
      orders: _orders,
      searchController: _searchController,
      onSearchChanged: (_) => setState(() {}),
      statusFilter: _statusFilter,
      onStatusFilterChanged: (status) {
        setState(() => _statusFilter = status);
      },
      selectedOrderId: _selectedOrder?.id,
      onOrderSelected: _selectOrder,
      periodLabel: _dateRange.label,
    );
  }

  Widget _buildDetails() {
    final order = _selectedOrder;
    if (order == null) return const OrdersEmptyDetails();

    return OrderDetailsPanel(
      order: order,
      onStatusChanged: (status) => _changeStatus(order, status),
    );
  }
}
