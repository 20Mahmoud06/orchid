import 'package:flutter_test/flutter_test.dart';
import 'package:orchid_admin/core/time/egypt_time.dart';

void main() {
  setUpAll(initTimeZones);

  group('Egypt time', () {
    test('uses EEST (UTC+3) during summer', () {
      final egypt = toEgyptTime(DateTime.utc(2026, 7, 15, 9));

      expect(egypt.hour, 12);
      expect(egypt.timeZoneOffset, const Duration(hours: 3));
    });

    test('returns to EET (UTC+2) after DST ends', () {
      final egypt = toEgyptTime(DateTime.utc(2026, 12, 15, 9));

      expect(egypt.hour, 11);
      expect(egypt.timeZoneOffset, const Duration(hours: 2));
    });

    test('switches automatically at the DST fall-back boundary', () {
      final before = toEgyptTime(DateTime.utc(2026, 10, 29, 20, 59));
      final after = toEgyptTime(DateTime.utc(2026, 10, 29, 21));

      expect(before.timeZoneOffset, const Duration(hours: 3));
      expect(after.timeZoneOffset, const Duration(hours: 2));
      expect(before.hour, 23);
      expect(after.hour, 23);
    });
  });
}
