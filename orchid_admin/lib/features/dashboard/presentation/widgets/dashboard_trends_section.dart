import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/time/date_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../../core/time/date_range.dart';
import '../../domain/models/dashboard_metrics.dart';
import 'dashboard_bar_chart.dart';

class DashboardTrendsSection extends StatelessWidget {
  const DashboardTrendsSection({
    super.key,
    required this.overview,
    required this.range,
    required this.isNarrow,
  });

  final DashboardOverview overview;
  final DateRange range;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final revenueCard = _TrendCard(
      title: 'Revenue over time',
      subtitle: 'Completed order value - ${range.rangeSummary}',
      value: '${overview.revenue.toStringAsFixed(0)} EGP',
      icon: Icons.trending_up_rounded,
      accent: AppColors.primary,
      buckets: overview.buckets,
      total: overview.revenue,
      emptyMessage: 'No completed revenue in this period.',
      valueOf: (bucket) => bucket.revenue,
      color: AppColors.primary,
      labelFor: (bucket) => _bucketLabel(
        bucket.bucketStart,
        range.grouping,
        overview.buckets.length,
      ),
      tooltipFor: (bucket) {
        final value = 'EGP ${bucket.revenue.toStringAsFixed(0)}';
        return '${_bucketTooltip(bucket.bucketStart, range.grouping)}\n$value';
      },
    );

    final ordersCard = _TrendCard(
      title: 'Orders over time',
      subtitle: 'Orders placed - ${range.rangeSummary}',
      value: overview.totalOrders.toString(),
      icon: Icons.bar_chart_rounded,
      accent: AppColors.orchidStrong,
      buckets: overview.buckets,
      total: overview.totalOrders.toDouble(),
      emptyMessage: 'No orders in this period.',
      valueOf: (bucket) => bucket.totalOrders.toDouble(),
      color: AppColors.orchidStrong,
      labelFor: (bucket) => _bucketLabel(
        bucket.bucketStart,
        range.grouping,
        overview.buckets.length,
      ),
      tooltipFor: (bucket) {
        final label = _bucketTooltip(bucket.bucketStart, range.grouping);
        final orders = bucket.totalOrders == 1
            ? '1 order'
            : '${bucket.totalOrders} orders';
        return '$label\n$orders';
      },
    );

    if (isNarrow) {
      return Column(
        children: [revenueCard, const SizedBox(height: 16), ordersCard],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: revenueCard),
        const SizedBox(width: 20),
        Expanded(child: ordersCard),
      ],
    );
  }

  static String _bucketLabel(
    DateTime bucketStart,
    DateRangeGrouping grouping,
    int bucketCount,
  ) {
    return switch (grouping) {
      DateRangeGrouping.hour => formatCompactHour(bucketStart),
      DateRangeGrouping.day =>
        bucketCount <= 10
            ? formatWeekdayShort(bucketStart)
            : '${bucketStart.day}',
      DateRangeGrouping.month => formatMonthShort(bucketStart),
    };
  }

  static String _bucketTooltip(
    DateTime bucketStart,
    DateRangeGrouping grouping,
  ) {
    return switch (grouping) {
      DateRangeGrouping.hour =>
        '${formatShortDate(bucketStart)} at ${formatClockTime(bucketStart)}',
      DateRangeGrouping.day => formatShortDate(bucketStart),
      DateRangeGrouping.month => formatMonthYear(bucketStart),
    };
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.accent,
    required this.buckets,
    required this.total,
    required this.emptyMessage,
    required this.valueOf,
    required this.color,
    required this.labelFor,
    required this.tooltipFor,
  });

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color accent;
  final List<DashboardBucket> buckets;
  final double total;
  final String emptyMessage;
  final double Function(DashboardBucket bucket) valueOf;
  final Color color;
  final String Function(DashboardBucket bucket) labelFor;
  final String Function(DashboardBucket bucket) tooltipFor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    CustomText(
                      text: subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    text: value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (total <= 0)
            _ChartEmptyState(message: emptyMessage)
          else
            DashboardBarChart(
              buckets: buckets,
              valueOf: valueOf,
              tooltipFor: tooltipFor,
              labelFor: labelFor,
              color: color,
            ),
        ],
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 214,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.show_chart_rounded,
            size: 28,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: message,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
