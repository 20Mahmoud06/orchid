import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orchid_admin/core/theme/app_theme.dart';
import 'package:orchid_admin/core/time/date_range.dart';
import 'package:orchid_admin/features/dashboard/domain/models/dashboard_metrics.dart';
import 'package:orchid_admin/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:orchid_admin/features/dashboard/presentation/widgets/dashboard_summary_grid.dart';
import 'package:orchid_admin/features/dashboard/presentation/widgets/dashboard_trends_section.dart';

void main() {
  testWidgets(
    'Dashboard summary and charts build at desktop and mobile sizes',
    (tester) async {
      final errors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() {
        FlutterError.onError = previousOnError;
      });

      final range = DateRange.resolve(
        DateRangePreset.last7Days,
        now: DateTime(2026, 1, 15, 10, 30),
      );
      final overview = DashboardOverview.fromRows([
        {
          'bucket_start': '2026-01-14T00:00:00',
          'total_orders': 4,
          'completed_orders': 3,
          'pending_orders': 1,
          'preparing_orders': 0,
          'canceled_orders': 0,
          'revenue': 1250,
        },
      ], range: range);

      for (final size in const [Size(1400, 900), Size(390, 844)]) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final isNarrow = size.width < 1100;
        final isMobile = size.width < 720;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        adminFirstName: 'Mahmoud',
                        dateRange: range,
                        onRangeChanged: (_) {},
                        isLoading: false,
                      ),
                      const SizedBox(height: 24),
                      DashboardSummaryGrid(
                        totalProducts: 12,
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(errors, isEmpty);
        expect(find.text('Revenue over time'), findsOneWidget);
        expect(find.text('Orders over time'), findsOneWidget);
      }
    },
  );
}
