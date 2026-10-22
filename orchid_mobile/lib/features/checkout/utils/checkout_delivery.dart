/// Next-day delivery slot and the labels shown across checkout.
class CheckoutDelivery {
  const CheckoutDelivery._();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
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

  /// Next-day delivery slot; the same value is stored on the order row so
  /// the admin can display it.
  static DateTime get slot {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 10);
  }

  static String get date {
    final deliverySlot = slot;
    return '${_weekdays[deliverySlot.weekday - 1]}, '
        '${deliverySlot.day} ${_months[deliverySlot.month - 1]} '
        '${deliverySlot.year}';
  }

  static const String time = 'between 10 a.m. to 2 p.m.';

  static String get dateTimeText => '$date\n$time';
}
