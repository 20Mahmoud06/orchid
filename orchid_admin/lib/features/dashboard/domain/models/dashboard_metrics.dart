import 'package:flutter/foundation.dart';

import '../../../../core/time/date_range.dart';

/// One aggregated point on the dashboard trend charts.
@immutable
class DashboardBucket {
  const DashboardBucket({
    required this.bucketStart,
    required this.totalOrders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.preparingOrders,
    required this.canceledOrders,
    required this.revenue,
  });

  final DateTime bucketStart;
  final int totalOrders;
  final int completedOrders;
  final int pendingOrders;
  final int preparingOrders;
  final int canceledOrders;
  final double revenue;

  factory DashboardBucket.zero(DateTime bucketStart) => DashboardBucket(
    bucketStart: bucketStart,
    totalOrders: 0,
    completedOrders: 0,
    pendingOrders: 0,
    preparingOrders: 0,
    canceledOrders: 0,
    revenue: 0,
  );

  DashboardBucket merge(DashboardBucket other) => DashboardBucket(
    bucketStart: bucketStart,
    totalOrders: totalOrders + other.totalOrders,
    completedOrders: completedOrders + other.completedOrders,
    pendingOrders: pendingOrders + other.pendingOrders,
    preparingOrders: preparingOrders + other.preparingOrders,
    canceledOrders: canceledOrders + other.canceledOrders,
    revenue: revenue + other.revenue,
  );
}

/// Aggregated orders and revenue for a dashboard period.
///
/// The summary cards and both trend charts are derived from this single
/// dataset so the whole dashboard stays consistent with the selected range.
@immutable
class DashboardOverview {
  const DashboardOverview({required this.buckets});

  final List<DashboardBucket> buckets;

  int get totalOrders =>
      buckets.fold(0, (sum, bucket) => sum + bucket.totalOrders);

  int get completedOrders =>
      buckets.fold(0, (sum, bucket) => sum + bucket.completedOrders);

  int get pendingOrders =>
      buckets.fold(0, (sum, bucket) => sum + bucket.pendingOrders);

  int get preparingOrders =>
      buckets.fold(0, (sum, bucket) => sum + bucket.preparingOrders);

  int get canceledOrders =>
      buckets.fold(0, (sum, bucket) => sum + bucket.canceledOrders);

  double get revenue => buckets.fold(0, (sum, bucket) => sum + bucket.revenue);

  bool get hasOrders => totalOrders > 0;

  bool get hasRevenue => revenue > 0;

  /// Builds an overview from the rows returned by the
  /// `dashboard_order_buckets` RPC and fills empty periods with zero buckets.
  factory DashboardOverview.fromRows(
    List<dynamic> rows, {
    required DateRange range,
  }) {
    final aggregated = <DateTime, DashboardBucket>{};

    for (final raw in rows) {
      if (raw is! Map) continue;
      final row = Map<String, dynamic>.from(raw);
      final rawBucket = row['bucket_start'];
      final parsed = rawBucket is DateTime
          ? rawBucket
          : DateTime.tryParse(rawBucket?.toString() ?? '');
      if (parsed == null) continue;

      final start = _normalize(parsed, range.grouping);
      final bucket = DashboardBucket(
        bucketStart: start,
        totalOrders: _asInt(row['total_orders']),
        completedOrders: _asInt(row['completed_orders']),
        pendingOrders: _asInt(row['pending_orders']),
        preparingOrders: _asInt(row['preparing_orders']),
        canceledOrders: _asInt(row['canceled_orders']),
        revenue: _asDouble(row['revenue']),
      );

      final existing = aggregated[start];
      aggregated[start] = existing == null ? bucket : existing.merge(bucket);
    }

    return DashboardOverview(buckets: _completeBuckets(aggregated, range));
  }

  static List<DashboardBucket> _completeBuckets(
    Map<DateTime, DashboardBucket> aggregated,
    DateRange range,
  ) {
    DateTime? first;
    DateTime? last;

    if (range.start != null && range.endExclusive != null) {
      first = _normalize(range.start!, range.grouping);
      last = _normalize(
        range.endExclusive!.subtract(const Duration(microseconds: 1)),
        range.grouping,
      );
    } else if (aggregated.isNotEmpty) {
      final keys = aggregated.keys.toList()..sort();
      first = keys.first;
      last = keys.last;
    }

    if (first == null || last == null) return const <DashboardBucket>[];

    final completed = <DashboardBucket>[];
    var cursor = first;
    var guard = 0;
    while (!cursor.isAfter(last) && guard < 5000) {
      completed.add(aggregated[cursor] ?? DashboardBucket.zero(cursor));
      cursor = _next(cursor, range.grouping);
      guard++;
    }
    return completed;
  }

  static DateTime _normalize(DateTime date, DateRangeGrouping grouping) {
    return switch (grouping) {
      DateRangeGrouping.hour => DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
      ),
      DateRangeGrouping.day => DateTime(date.year, date.month, date.day),
      DateRangeGrouping.month => DateTime(date.year, date.month),
    };
  }

  static DateTime _next(DateTime date, DateRangeGrouping grouping) {
    return switch (grouping) {
      DateRangeGrouping.hour => DateTime(
        date.year,
        date.month,
        date.day,
        date.hour + 1,
      ),
      DateRangeGrouping.day => DateTime(date.year, date.month, date.day + 1),
      DateRangeGrouping.month => DateTime(date.year, date.month + 1),
    };
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
