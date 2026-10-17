import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/auth_service.dart';
import '../../../orders/data/repositories/orders_repository.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../products/data/repositories/products_repository.dart';
import '../../../products/domain/models/product_model.dart';
import '../widgets/recent_orders_table.dart';
import '../widgets/summary_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _productsRepository = ProductsRepository();
  final _ordersRepository = OrdersRepository();

  List<Product> _products = const [];
  List<Order> _orders = const [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        _productsRepository.getAllProducts(),
        _ordersRepository.getAllOrders(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = results[0] as List<Product>;
        _orders = results[1] as List<Order>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalProducts => _products.length;
  int get _totalOrders => _orders.length;
  int get _newOrders =>
      _orders.where((order) => order.status == OrderStatus.pending).length;
  int get _preparingOrders =>
      _orders.where((order) => order.status == OrderStatus.preparing).length;
  double get _completedSales => _orders
      .where((order) => order.status == OrderStatus.completed)
      .fold(0, (sum, order) => sum + order.total);

  List<Order> get _recentOrders {
    final sorted = List<Order>.from(_orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1100;
        final isMobile = constraints.maxWidth < 720;

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeRow(context, isMobile: isMobile),
                  const SizedBox(height: 28),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child:
                          Center(child: CircularProgressIndicator()),
                    )
                  else if (_loadError != null)
                    _buildErrorState()
                  else ...[
                    _buildSummaryRow(
                        isNarrow: isNarrow, isMobile: isMobile),
                    const SizedBox(height: 24),
                    RecentOrdersTable(
                      orders: _recentOrders,
                      totalOrders: _orders.length,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
          Text('Failed to load dashboard', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(_loadError ?? '',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeRow(BuildContext context, {required bool isMobile}) {
    final title = Text(
      'Welcome back, ${AuthService.adminFirstName}',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
    final subtitle = Text(
      'Here is what is happening with your store today.',
      style: AppTextStyles.bodySecondary,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 6),
        subtitle,
      ],
    );
  }

  Widget _buildSummaryRow({required bool isNarrow, required bool isMobile}) {
    final cards = [
      SummaryCard(
        label: 'Total Products',
        value: _totalProducts.toString(),
        subtitle: 'In your catalog',
        icon: Icons.eco_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.textSecondary,
      ),
      SummaryCard(
        label: 'Total Orders',
        value: _totalOrders.toString(),
        subtitle: 'All time',
        icon: Icons.shopping_bag_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.textSecondary,
      ),
      SummaryCard(
        label: 'New Orders',
        value: _newOrders.toString(),
        subtitle: 'Waiting to be accepted',
        icon: Icons.fiber_new_outlined,
        accentColor: AppColors.warning,
        subtitleColor: AppColors.warning,
      ),
      SummaryCard(
        label: 'Preparing Orders',
        value: _preparingOrders.toString(),
        subtitle: 'Awaiting completion',
        icon: Icons.hourglass_bottom_rounded,
        accentColor: AppColors.orchidStrong,
        subtitleColor: AppColors.orchidStrong,
      ),
      SummaryCard(
        label: 'Completed Sales',
        value: '${_completedSales.toStringAsFixed(0)} EGP',
        subtitle: 'From completed orders',
        icon: Icons.payments_outlined,
        accentColor: AppColors.primary,
        subtitleColor: AppColors.success,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    if (isNarrow) {
      final rows = <List<SummaryCard>>[
        for (int i = 0; i < cards.length; i += 2) cards.sublist(i, i + 2 > cards.length ? cards.length : i + 2),
      ];
      return Column(
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            Row(
              children: [
                for (int c = 0; c < rows[r].length; c++) ...[
                  Expanded(child: rows[r][c]),
                  if (c < rows[r].length - 1) const SizedBox(width: 16),
                ],
              ],
            ),
            if (r < rows.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}
