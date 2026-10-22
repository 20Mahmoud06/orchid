import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Everything `flutter test` needs in order to boot the real app.
///
/// Without these the app renders nothing at all: `AppPrefs` throws
/// `MissingPluginException`, and `Supabase.instance` asserts.
class TestHarness {
  TestHarness._();

  static bool _fontsLoaded = false;

  /// The font families declared in `pubspec.yaml`.
  static const fonts = <String, String>{
    'Goudy Old Style': 'assets/fonts/goudy-old-style/GOUDOS.TTF',
    'Goudy Bookletter 1911':
        'assets/fonts/Goudy_Bookletter_1911/GoudyBookletter1911-Regular.ttf',
    'Inria Serif': 'assets/fonts/Inria_Serif/InriaSerif-Regular.ttf',
  };

  /// Sets up fonts, preferences and Supabase.
  ///
  /// Nothing is fetched: `currentSession` stays null, so a cold boot lands on
  /// the login screen exactly like a first run on a device.
  static Future<void> boot({WidgetTester? tester}) async {
    await loadFonts();
    seedPreferences();
    if (tester != null) useDesignSize(tester);
    await initSupabase();
  }

  /// Registers the app's real font files with the test font collection.
  ///
  /// Without this every glyph falls back to Flutter's test font, which draws
  /// each character as a full em square. Text then measures roughly twice as
  /// wide as it does on a phone, which shows up as bogus `RenderFlex`
  /// overflows on screens that are perfectly fine in production.
  static Future<void> loadFonts() async {
    if (_fontsLoaded) return;
    for (final entry in fonts.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
    _fontsLoaded = true;
  }

  /// Seeds an (empty by default) preference store.
  static void seedPreferences([Map<String, Object> values = const {}]) {
    SharedPreferences.setMockInitialValues(values);
  }

  /// Removes every platform handler installed here.
  static void tearDown() {
    SharedPreferences.setMockInitialValues({});
  }

  /// Boots Supabase without touching the network.
  static Future<void> initSupabase() async {
    seedPreferences();
    await Supabase.initialize(
      url: 'https://orchid-test.supabase.co',
      publishableKey: 'sb_publishable_unit_test_key',
    );
  }

  /// Matches the surface the app is designed for.
  ///
  /// The default 800x600 test window makes `flutter_screenutil` scale
  /// `.w`/`.h` against the wrong size, so every hard coded dimension in the app
  /// comes out wrong.
  static void useDesignSize(WidgetTester tester) {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
  }
}
