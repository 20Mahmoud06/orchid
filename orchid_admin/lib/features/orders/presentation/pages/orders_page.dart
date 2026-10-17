import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/repositories/orders_repository.dart';
import '../../domain/models/order_model.dart';
import '../widgets/order_details_panel.dart';
import '../widgets/order_status_badge.dart';

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
  bool _isLoading = true;
  String? _loadError;
  RealtimeChannel? _channel;
  Timer? _debounce;

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
    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final orders = await _repository.getAllOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
        _loadError = null;
        // Keep the currently selected order in sync with the fresh data.
        final selectedId = _selectedOrder?.id;
        _selectedOrder = null;
        if (selectedId != null) {
          for (final order in orders) {
            if (order.id == selectedId) {
              _selectedOrder = order;
              break;
            }
          }
        }
        _selectedOrder ??= orders.isNotEmpty ? orders.first : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
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
            _debounce = Timer(const Duration(milliseconds: 600),
                () => _load(silent: true));
          },
        )
        .subscribe();
  }

  List<Order> get _filteredOrders {
    var orders = List<Order>.from(_orders);
    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      orders = orders
          .where(
            (order) =>
                order.orderCode.toLowerCase().contains(query) ||
                (order.customerName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (_statusFilter != null) {
      orders = orders.where((order) => order.status == _statusFilter).toList();
    }

    return orders;
  }

  void _selectOrder(Order order) {
    setState(() => _selectedOrder = order);
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

  int _countFor(OrderStatus? status) => status == null
      ? _orders.length
      : _orders.where((order) => order.status == status).length;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 1100;
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile: isMobile),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                _buildErrorState()
              else if (isNarrow)
                Column(
                  children: [
                    _buildOrdersListCard(_filteredOrders),
                    const SizedBox(height: 20),
                    _selectedOrder != null
                        ? OrderDetailsPanel(
                            order: _selectedOrder!,
                            onStatusChanged: (status) =>
                                _changeStatus(_selectedOrder!, status),
                          )
                        : _buildEmptyDetails(),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: _buildOrdersListCard(_filteredOrders)),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: _selectedOrder != null
                          ? OrderDetailsPanel(
                              order: _selectedOrder!,
                              onStatusChanged: (status) =>
                                  _changeStatus(_selectedOrder!, status),
                            )
                          : _buildEmptyDetails(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load orders', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(_loadError ?? '',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          AppButton(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: () => _load(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    final title = Text(
      'Orders',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
    final subtitle = Text(
      'Live customer orders from the Orchid mobile app.',
      style: AppTextStyles.bodySecondary,
    );
    final button = AppButton(
      label: 'Refresh',
      icon: Icons.refresh_rounded,
      variant: AppButtonVariant.outline,
      onPressed: () => _load(),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 16),
          button,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              subtitle,
            ],
          ),
        ),
        button,
      ],
    );
  }

  Widget _buildOrdersListCard(List<Order> filtered) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildTabs(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Search by order code or customer name...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.search,
                      size: 18, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'ORDERS QUEUE',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Showing ${filtered.length} of ${_orders.length}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('No orders found.',
                    style: AppTextStyles.bodySecondary),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final order = filtered[index];
                return _OrderListTile(
                  order: order,
                  isSelected: _selectedOrder?.id == order.id,
                  onTap: () => _selectOrder(order),
                );
              },
            ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              '${_orders.length} order${_orders.length == 1 ? '' : 's'} total',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _OrderTab(
            label: 'All',
            count: _countFor(null),
            isSelected: _statusFilter == null,
            onTap: () => setState(() => _statusFilter = null),
          ),
          _OrderTab(
            label: 'New',
            count: _countFor(OrderStatus.pending),
            isSelected: _statusFilter == OrderStatus.pending,
            onTap: () => setState(() => _statusFilter = OrderStatus.pending),
          ),
          _OrderTab(
            label: 'Preparing',
            count: _countFor(OrderStatus.preparing),
            isSelected: _statusFilter == OrderStatus.preparing,
            onTap: () => setState(() => _statusFilter = OrderStatus.preparing),
          ),
          _OrderTab(
            label: 'Completed',
            count: _countFor(OrderStatus.completed),
            isSelected: _statusFilter == OrderStatus.completed,
            onTap: () => setState(() => _statusFilter = OrderStatus.completed),
          ),
          _OrderTab(
            label: 'Cancelled',
            count: _countFor(OrderStatus.canceled),
            isSelected: _statusFilter == OrderStatus.canceled,
            onTap: () => setState(() => _statusFilter = OrderStatus.canceled),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDetails() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Select an order to view details',
                style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final Order order;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = OrderStatusVisual.forStatus(order.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.orchidSoft1 : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visual.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(visual.icon, size: 18, color: visual.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '#${order.orderCode}',
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (order.customerName?.isNotEmpty ?? false)
                        ? order.customerName!
                        : 'Customer',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(_formatListDate(order.createdAt),
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.total.toStringAsFixed(0)} EGP',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatListDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final time =
        '${hour.toString().padLeft(2, '0')}:$minute $period';

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, $time';
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, $time';
    }
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
