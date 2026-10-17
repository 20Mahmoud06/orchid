import 'package:shared_preferences/shared_preferences.dart';

/// Local preferences abstraction backed by `shared_preferences` for persistent
/// app settings (remember-me flag, cached values, etc).
///
/// Named [AppPrefs] (rather than LocalStorage) to avoid colliding with the
/// `LocalStorage` type exported by `supabase_flutter`.
class AppPrefs {
  AppPrefs._();

  static final AppPrefs instance = AppPrefs._();

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}