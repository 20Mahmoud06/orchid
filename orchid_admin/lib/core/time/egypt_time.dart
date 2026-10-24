import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Cairo location used to render server timestamps in Egypt time, regardless
/// of where the admin app is opened from.
final tz.Location _cairo = tz.getLocation('Africa/Cairo');

/// Loads the bundled timezone database. Must be called once before any
/// timestamp is converted (see `main()`).
void initTimeZones() => tzdata.initializeTimeZones();

/// Converts a timestamp as returned by Supabase (UTC, `timestamptz`) into its
/// Cairo wall-clock time.
DateTime toEgyptTime(DateTime utc) => tz.TZDateTime.from(utc, _cairo);

/// Current Cairo wall-clock time, independent of the browser's timezone.
DateTime nowInEgypt() => tz.TZDateTime.now(_cairo);

/// Converts a Cairo wall-clock [DateTime] into the matching UTC instant.
///
/// Used to build inclusive/exclusive query boundaries for `timestamptz`
/// columns without depending on the machine's local timezone.
DateTime egyptWallClockToUtc(DateTime wallClock) {
  return tz.TZDateTime(
    _cairo,
    wallClock.year,
    wallClock.month,
    wallClock.day,
    wallClock.hour,
    wallClock.minute,
    wallClock.second,
    wallClock.millisecond,
    wallClock.microsecond,
  ).toUtc();
}
