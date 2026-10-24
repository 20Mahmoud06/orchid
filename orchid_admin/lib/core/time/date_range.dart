import 'package:flutter/foundation.dart';

import 'date_formatter.dart';
import 'egypt_time.dart';

/// The period choices shown in date-range selectors across the admin app.
enum DateRangePreset {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  thisWeek('This Week'),
  lastWeek('Last Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year'),
  allTime('All Time'),
  custom('Custom Range');

  const DateRangePreset(this.label);

  final String label;
}

/// Granularity used for time-series buckets.
enum DateRangeGrouping {
  hour('hour'),
  day('day'),
  month('month');

  const DateRangeGrouping(this.dbValue);

  final String dbValue;
}

/// A resolved period expressed as Cairo wall-clock dates.
///
/// [start] is inclusive and [endExclusive] is exclusive. Both are converted to
/// UTC only when building Supabase query boundaries, which keeps business-day
/// boundaries in Egypt regardless of the browser's timezone.
@immutable
class DateRange {
  const DateRange._({required this.preset, this.start, this.endExclusive});

  static const DateRange allTime = DateRange._(preset: DateRangePreset.allTime);

  final DateRangePreset preset;
  final DateTime? start;
  final DateTime? endExclusive;

  bool get isAllTime => preset == DateRangePreset.allTime;

  DateTime? get endInclusive {
    final end = endExclusive;
    return end == null ? null : _addDays(end, -1);
  }

  DateTime? get startUtc {
    final value = start;
    return value == null ? null : egyptWallClockToUtc(value);
  }

  DateTime? get endUtc {
    final value = endExclusive;
    return value == null ? null : egyptWallClockToUtc(value);
  }

  String get label => preset.label;

  /// A human-readable description of the actual dates covered by this range.
  String get rangeSummary {
    if (isAllTime) return 'All recorded orders';

    final rangeStart = start;
    final rangeEnd = endInclusive;
    if (rangeStart == null || rangeEnd == null) return label;

    if (_isSameDay(rangeStart, rangeEnd)) {
      return formatShortDate(rangeStart);
    }
    return '${formatShortDate(rangeStart)} - ${formatShortDate(rangeEnd)}';
  }

  DateRangeGrouping get grouping {
    switch (preset) {
      case DateRangePreset.today:
      case DateRangePreset.yesterday:
        return DateRangeGrouping.hour;
      case DateRangePreset.last7Days:
      case DateRangePreset.last30Days:
      case DateRangePreset.thisWeek:
      case DateRangePreset.lastWeek:
      case DateRangePreset.thisMonth:
      case DateRangePreset.lastMonth:
        return DateRangeGrouping.day;
      case DateRangePreset.thisYear:
      case DateRangePreset.allTime:
        return DateRangeGrouping.month;
      case DateRangePreset.custom:
        final rangeStart = start;
        final rangeEnd = endExclusive;
        if (rangeStart == null || rangeEnd == null) {
          return DateRangeGrouping.day;
        }
        final days = rangeEnd.difference(rangeStart).inDays;
        return days <= 31 ? DateRangeGrouping.day : DateRangeGrouping.month;
    }
  }

  /// Resolves a preset against [now], which must be an Egypt wall-clock time.
  ///
  /// Weeks follow the ISO convention: Monday through Sunday.
  factory DateRange.resolve(
    DateRangePreset preset, {
    required DateTime now,
    DateTime? customStart,
    DateTime? customEndInclusive,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = _addDays(today, 1);
    final weekStart = _addDays(today, -(today.weekday - 1));

    switch (preset) {
      case DateRangePreset.today:
        return DateRange._(
          preset: preset,
          start: today,
          endExclusive: tomorrow,
        );
      case DateRangePreset.yesterday:
        return DateRange._(
          preset: preset,
          start: _addDays(today, -1),
          endExclusive: today,
        );
      case DateRangePreset.last7Days:
        return DateRange._(
          preset: preset,
          start: _addDays(today, -6),
          endExclusive: tomorrow,
        );
      case DateRangePreset.last30Days:
        return DateRange._(
          preset: preset,
          start: _addDays(today, -29),
          endExclusive: tomorrow,
        );
      case DateRangePreset.thisWeek:
        return DateRange._(
          preset: preset,
          start: weekStart,
          endExclusive: tomorrow,
        );
      case DateRangePreset.lastWeek:
        return DateRange._(
          preset: preset,
          start: _addDays(weekStart, -7),
          endExclusive: weekStart,
        );
      case DateRangePreset.thisMonth:
        return DateRange._(
          preset: preset,
          start: DateTime(today.year, today.month),
          endExclusive: tomorrow,
        );
      case DateRangePreset.lastMonth:
        return DateRange._(
          preset: preset,
          start: DateTime(today.year, today.month - 1),
          endExclusive: DateTime(today.year, today.month),
        );
      case DateRangePreset.thisYear:
        return DateRange._(
          preset: preset,
          start: DateTime(today.year),
          endExclusive: tomorrow,
        );
      case DateRangePreset.allTime:
        return allTime;
      case DateRangePreset.custom:
        final rangeStart = customStart;
        final rangeEnd = customEndInclusive;
        if (rangeStart == null || rangeEnd == null) {
          throw ArgumentError(
            'A custom range requires both a start date and an end date.',
          );
        }
        return DateRange.custom(start: rangeStart, end: rangeEnd);
    }
  }

  /// Builds an inclusive custom calendar range.
  factory DateRange.custom({required DateTime start, required DateTime end}) {
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day);
    if (rangeStart.isAfter(rangeEnd)) {
      throw ArgumentError('The start date must not be after the end date.');
    }

    return DateRange._(
      preset: DateRangePreset.custom,
      start: rangeStart,
      endExclusive: _addDays(rangeEnd, 1),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DateRange &&
        other.preset == preset &&
        other.start == start &&
        other.endExclusive == endExclusive;
  }

  @override
  int get hashCode => Object.hash(preset, start, endExclusive);

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
