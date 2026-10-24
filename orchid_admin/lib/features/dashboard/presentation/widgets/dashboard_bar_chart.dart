import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../domain/models/dashboard_metrics.dart';

/// Lightweight bar chart built from the project's existing design widgets.
///
/// Values are intentionally not grouped by the chart itself; the dashboard
/// range decides whether buckets represent hours, days, or months.
class DashboardBarChart extends StatelessWidget {
  const DashboardBarChart({
    super.key,
    required this.buckets,
    required this.valueOf,
    required this.tooltipFor,
    required this.labelFor,
    required this.color,
  });

  final List<DashboardBucket> buckets;
  final double Function(DashboardBucket bucket) valueOf;
  final String Function(DashboardBucket bucket) tooltipFor;
  final String Function(DashboardBucket bucket) labelFor;
  final Color color;

  static const double _chartHeight = 190;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox(height: _chartHeight);

    var maxValue = 0.0;
    for (final bucket in buckets) {
      final value = valueOf(bucket);
      if (value > maxValue) maxValue = value;
    }

    final labelStep = _labelStep(buckets.length);
    final gap = buckets.length > 20 ? 1.0 : 3.0;

    return Column(
      children: [
        SizedBox(
          height: _chartHeight,
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, child: _GridLine()),
              Positioned(
                top: _chartHeight / 2,
                left: 0,
                right: 0,
                child: _GridLine(),
              ),
              Positioned(bottom: 0, left: 0, right: 0, child: _GridLine()),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final bucket in buckets)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: gap),
                          child: _Bar(
                            value: valueOf(bucket),
                            maxValue: maxValue,
                            color: color,
                            maxHeight: _chartHeight - 4,
                            tooltip: tooltipFor(bucket),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var index = 0; index < buckets.length; index++)
              Expanded(
                child: SizedBox(
                  height: 16,
                  child: index % labelStep == 0 || index == buckets.length - 1
                      ? Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: CustomText(
                              text: labelFor(buckets[index]),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ],
    );
  }

  static int _labelStep(int bucketCount) {
    if (bucketCount <= 7) return 1;
    if (bucketCount <= 12) return 2;
    if (bucketCount <= 24) return 3;
    return (bucketCount / 8).ceil();
  }
}

class _GridLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.65),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.maxHeight,
    required this.tooltip,
  });

  final double value;
  final double maxValue;
  final Color color;
  final double maxHeight;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final height = value <= 0
        ? 2.0
        : ((value / (maxValue <= 0 ? 1 : maxValue)) * maxHeight)
              .clamp(4.0, maxHeight)
              .toDouble();

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: value <= 0 ? AppColors.border : color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}
