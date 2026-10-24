import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_error_state.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_summary_grid.dart';
import '../widgets/dashboard_trends_section.dart';
import '../widgets/recent_orders_table.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showMoreRecentOrders() async {
    final succeeded = await _controller.loadMoreRecentOrders();
    if (!succeeded && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not load more orders. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 1100;
            final isMobile = constraints.maxWidth < 720;
            final range = _controller.selectedRange;
            final overview = _controller.overview;

            return ColoredBox(
              color: AppColors.background,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        adminFirstName: AuthService.adminFirstName,
                        dateRange: range,
                        onRangeChanged: (value) =>
                            unawaited(_controller.selectRange(value)),
                        isLoading: _controller.isLoading,
                      ),
                      const SizedBox(height: 28),
                      if (_controller.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_controller.error != null)
                        DashboardErrorState(
                          message: _controller.error!,
                          onRetry: () => unawaited(_controller.load()),
                        )
                      else if (overview != null) ...[
                        DashboardSummaryGrid(
                          totalProducts: _controller.productCount,
                          totalOrders: overview.totalOrders,
                          completedOrders: overview.completedOrders,
                          newOrders: overview.pendingOrders,
                          preparingOrders: overview.preparingOrders,
                          canceledOrders: overview.canceledOrders,
                          completedSales: overview.revenue,
                          periodLabel: range.label,
                          isNarrow: isNarrow,
                          isMobile: isMobile,
                        ),
                        const SizedBox(height: 24),
                        DashboardTrendsSection(
                          overview: overview,
                          range: range,
                          isNarrow: isNarrow,
                        ),
                        const SizedBox(height: 24),
                        RecentOrdersTable(
                          orders: _controller.recentOrders,
                          totalOrders: overview.totalOrders,
                          periodLabel: range.label,
                          onShowMore: _controller.hasMoreRecentOrders
                              ? _showMoreRecentOrders
                              : null,
                          isLoadingMore: _controller.isLoadingMore,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
