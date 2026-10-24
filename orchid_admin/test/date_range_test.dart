import 'package:flutter_test/flutter_test.dart';
import 'package:orchid_admin/core/time/date_range.dart';
import 'package:orchid_admin/core/time/egypt_time.dart';

void main() {
  // Thursday, 15 January 2026, 10:30 AM Cairo wall-clock time.
  final now = DateTime(2026, 1, 15, 10, 30);

  group('DateRange', () {
    test('Today covers the current calendar day', () {
      final range = DateRange.resolve(DateRangePreset.today, now: now);

      expect(range.start, DateTime(2026, 1, 15));
      expect(range.endExclusive, DateTime(2026, 1, 16));
      expect(range.grouping, DateRangeGrouping.hour);
      expect(range.rangeSummary, 'Jan 15, 2026');
    });

    test('Yesterday covers the previous calendar day', () {
      final range = DateRange.resolve(DateRangePreset.yesterday, now: now);

      expect(range.start, DateTime(2026, 1, 14));
      expect(range.endExclusive, DateTime(2026, 1, 15));
      expect(range.grouping, DateRangeGrouping.hour);
    });

    test('Last 7 Days includes today and the previous six days', () {
      final range = DateRange.resolve(DateRangePreset.last7Days, now: now);

      expect(range.start, DateTime(2026, 1, 9));
      expect(range.endExclusive, DateTime(2026, 1, 16));
      expect(range.grouping, DateRangeGrouping.day);
    });

    test('Last 30 Days includes today and the previous twenty-nine days', () {
      final range = DateRange.resolve(DateRangePreset.last30Days, now: now);

      expect(range.start, DateTime(2025, 12, 17));
      expect(range.endExclusive, DateTime(2026, 1, 16));
      expect(range.grouping, DateRangeGrouping.day);
    });

    test('This Week starts on Monday', () {
      final range = DateRange.resolve(DateRangePreset.thisWeek, now: now);

      expect(range.start, DateTime(2026, 1, 12));
      expect(range.endExclusive, DateTime(2026, 1, 16));
    });

    test('Last Week is the complete previous Monday-Sunday week', () {
      final range = DateRange.resolve(DateRangePreset.lastWeek, now: now);

      expect(range.start, DateTime(2026, 1, 5));
      expect(range.endExclusive, DateTime(2026, 1, 12));
    });

    test('This Month starts on the first day of the current month', () {
      final range = DateRange.resolve(DateRangePreset.thisMonth, now: now);

      expect(range.start, DateTime(2026, 1, 1));
      expect(range.endExclusive, DateTime(2026, 1, 16));
    });

    test('Last Month is the complete previous calendar month', () {
      final range = DateRange.resolve(DateRangePreset.lastMonth, now: now);

      expect(range.start, DateTime(2025, 12, 1));
      expect(range.endExclusive, DateTime(2026, 1, 1));
    });

    test('This Year starts on January 1', () {
      final range = DateRange.resolve(DateRangePreset.thisYear, now: now);

      expect(range.start, DateTime(2026, 1, 1));
      expect(range.endExclusive, DateTime(2026, 1, 16));
      expect(range.grouping, DateRangeGrouping.month);
    });

    test('All Time has no boundaries and uses monthly grouping', () {
      final range = DateRange.resolve(DateRangePreset.allTime, now: now);

      expect(range, DateRange.allTime);
      expect(range.start, isNull);
      expect(range.endExclusive, isNull);
      expect(range.grouping, DateRangeGrouping.month);
      expect(range.rangeSummary, 'All recorded orders');
    });

    test('Custom range treats both selected dates as inclusive', () {
      final range = DateRange.custom(
        start: DateTime(2026, 1, 3, 18),
        end: DateTime(2026, 1, 5, 4),
      );

      expect(range.start, DateTime(2026, 1, 3));
      expect(range.endExclusive, DateTime(2026, 1, 6));
      expect(range.endInclusive, DateTime(2026, 1, 5));
      expect(range.grouping, DateRangeGrouping.day);
      expect(range.rangeSummary, 'Jan 3, 2026 - Jan 5, 2026');
    });

    test('Custom range longer than a month switches to monthly grouping', () {
      final range = DateRange.custom(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 2, 9),
      );

      expect(range.grouping, DateRangeGrouping.month);
    });

    test('Custom range rejects a start date after the end date', () {
      expect(
        () => DateRange.custom(
          start: DateTime(2026, 1, 10),
          end: DateTime(2026, 1, 5),
        ),
        throwsArgumentError,
      );
    });

    test('UTC boundaries follow Cairo time, not the machine timezone', () {
      initTimeZones();

      final range = DateRange.resolve(DateRangePreset.today, now: now);

      expect(
        range.startUtc!.isAtSameMomentAs(DateTime.utc(2026, 1, 14, 22)),
        isTrue,
      );
      expect(
        range.endUtc!.isAtSameMomentAs(DateTime.utc(2026, 1, 15, 22)),
        isTrue,
      );
    });

    test('UTC boundaries use Egypt summer time (UTC+3) during DST', () {
      initTimeZones();

      final summerNow = DateTime(2026, 7, 15, 10, 30);
      final range = DateRange.resolve(DateRangePreset.today, now: summerNow);

      expect(
        range.startUtc!.isAtSameMomentAs(DateTime.utc(2026, 7, 14, 21)),
        isTrue,
      );
      expect(
        range.endUtc!.isAtSameMomentAs(DateTime.utc(2026, 7, 15, 21)),
        isTrue,
      );
    });
  });
}
