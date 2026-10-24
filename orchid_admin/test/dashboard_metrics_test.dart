import 'package:flutter_test/flutter_test.dart';
import 'package:orchid_admin/core/time/date_range.dart';
import 'package:orchid_admin/features/dashboard/domain/models/dashboard_metrics.dart';

void main() {
  final now = DateTime(2026, 1, 15, 10, 30);

  Map<String, dynamic> row({
    required String bucket,
    int total = 0,
    int completed = 0,
    int pending = 0,
    int preparing = 0,
    int canceled = 0,
    num revenue = 0,
  }) {
    return {
      'bucket_start': bucket,
      'total_orders': total,
      'completed_orders': completed,
      'pending_orders': pending,
      'preparing_orders': preparing,
      'canceled_orders': canceled,
      'revenue': revenue,
    };
  }

  group('DashboardOverview', () {
    test('aggregates statuses and revenue from RPC buckets', () {
      final range = DateRange.resolve(DateRangePreset.last7Days, now: now);

      final overview = DashboardOverview.fromRows([
        row(
          bucket: '2026-01-09T00:00:00',
          total: 3,
          completed: 2,
          pending: 1,
          revenue: 500,
        ),
        row(
          bucket: '2026-01-15T00:00:00',
          total: 2,
          completed: 1,
          preparing: 1,
          revenue: 200,
        ),
        row(bucket: '2026-01-15T00:00:00', total: 1, canceled: 1),
      ], range: range);

      expect(overview.buckets, hasLength(7));
      expect(overview.buckets.first.bucketStart, DateTime(2026, 1, 9));
      expect(overview.totalOrders, 6);
      expect(overview.completedOrders, 3);
      expect(overview.pendingOrders, 1);
      expect(overview.preparingOrders, 1);
      expect(overview.canceledOrders, 1);
      expect(overview.revenue, 700);
      expect(overview.hasOrders, isTrue);
      expect(overview.hasRevenue, isTrue);
    });

    test('fills missing days with zero buckets', () {
      final range = DateRange.resolve(DateRangePreset.last7Days, now: now);

      final overview = DashboardOverview.fromRows([
        row(bucket: '2026-01-09T00:00:00', total: 1, completed: 1),
      ], range: range);

      expect(overview.buckets, hasLength(7));
      expect(overview.buckets[2].bucketStart, DateTime(2026, 1, 11));
      expect(overview.buckets[2].totalOrders, 0);
      expect(overview.buckets[6].bucketStart, DateTime(2026, 1, 15));
    });

    test('builds 24 hourly buckets for Today', () {
      final range = DateRange.resolve(DateRangePreset.today, now: now);

      final overview = DashboardOverview.fromRows([
        row(bucket: '2026-01-15T03:00:00', total: 1),
        row(bucket: '2026-01-15T14:00:00', total: 2),
      ], range: range);

      expect(overview.buckets, hasLength(24));
      expect(overview.buckets[0].bucketStart, DateTime(2026, 1, 15));
      expect(overview.buckets[3].totalOrders, 1);
      expect(overview.buckets[14].totalOrders, 2);
      expect(overview.totalOrders, 3);
    });

    test('returns zero-filled buckets for a period with no orders', () {
      final range = DateRange.resolve(DateRangePreset.last7Days, now: now);

      final overview = DashboardOverview.fromRows(const [], range: range);

      expect(overview.buckets, hasLength(7));
      expect(overview.totalOrders, 0);
      expect(overview.revenue, 0);
      expect(overview.hasOrders, isFalse);
      expect(overview.hasRevenue, isFalse);
    });

    test('All Time fills gaps between the first and last data buckets', () {
      final range = DateRange.resolve(DateRangePreset.allTime, now: now);

      final overview = DashboardOverview.fromRows([
        row(bucket: '2025-01-01T00:00:00', total: 2, completed: 1),
        row(bucket: '2025-03-01T00:00:00', total: 4, completed: 3),
      ], range: range);

      expect(overview.buckets, hasLength(3));
      expect(overview.buckets[0].bucketStart, DateTime(2025, 1));
      expect(overview.buckets[1].bucketStart, DateTime(2025, 2));
      expect(overview.buckets[1].totalOrders, 0);
      expect(overview.buckets[2].bucketStart, DateTime(2025, 3));
      expect(overview.totalOrders, 6);
    });

    test('All Time with no orders has no buckets', () {
      final range = DateRange.resolve(DateRangePreset.allTime, now: now);

      final overview = DashboardOverview.fromRows(const [], range: range);

      expect(overview.buckets, isEmpty);
      expect(overview.totalOrders, 0);
    });

    test('ignores malformed rows and parses numeric strings', () {
      final range = DateRange.resolve(DateRangePreset.last7Days, now: now);

      final overview = DashboardOverview.fromRows([
        null,
        'not a row',
        row(bucket: 'not-a-date', total: 4),
        {
          'bucket_start': '2026-01-15T00:00:00',
          'total_orders': '2',
          'completed_orders': '1',
          'revenue': '99.5',
        },
      ], range: range);

      expect(overview.totalOrders, 2);
      expect(overview.completedOrders, 1);
      expect(overview.revenue, 99.5);
    });
  });
}
