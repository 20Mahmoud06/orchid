import 'egypt_time.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _fullMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

String formatShortDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

String formatMonthYear(DateTime date) =>
    '${_fullMonths[date.month - 1]} ${date.year}';

String formatMonthShort(DateTime date) => _months[date.month - 1];

String formatWeekdayShort(DateTime date) => _weekdays[date.weekday - 1];

String formatCompactHour(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  return '$hour${date.hour >= 12 ? 'p' : 'a'}';
}

String formatClockTime(DateTime date, {bool padHour = false}) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final hourText = padHour ? hour.toString().padLeft(2, '0') : '$hour';
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hourText:$minute $period';
}

String formatRecentDate(DateTime date) {
  final now = nowInEgypt();

  if (_isSameDay(date, now)) return 'Today';
  if (_isSameDay(date, _previousDay(now))) {
    return 'Yesterday';
  }
  return formatShortDate(date);
}

String formatRelativeTimestamp(DateTime date) {
  final now = nowInEgypt();
  final time = formatClockTime(date, padHour: true);

  if (_isSameDay(date, now)) return 'Today, $time';
  if (_isSameDay(date, _previousDay(now))) {
    return 'Yesterday, $time';
  }
  return formatShortDate(date);
}

String formatPlacedAt(DateTime date) {
  final formatted = '${formatShortDate(date)} at ${formatClockTime(date)}';
  return _isSameDay(date, nowInEgypt()) ? 'Today, $formatted' : formatted;
}

DateTime _previousDay(DateTime date) =>
    DateTime(date.year, date.month, date.day - 1);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
