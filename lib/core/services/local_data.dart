import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  PreferencesService._();

  static Future<void> init() async {
    if (_instance != null) return;

    _prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService._();
  }

  /// 🔹 Dùng ở mọi nơi
  static PreferencesService get instance {
    if (_instance == null || _prefs == null) {
      throw Exception(
        'PreferencesService not initialized. '
        'Call PreferencesService.init() before using.',
      );
    }
    return _instance!;
  }

  // ================= GETTER =================

  String? getString(String key) => _prefs!.getString(key);
  int? getInt(String key) => _prefs!.getInt(key);
  bool getBool(String key) => _prefs!.getBool(key) ?? false;
  double? getDouble(String key) => _prefs!.getDouble(key);

  // ================= SETTER =================

  Future<void> setString(String key, String value) =>
      _prefs!.setString(key, value);

  Future<void> setInt(String key, int value) => _prefs!.setInt(key, value);

  Future<void> setBool(String key, bool value) => _prefs!.setBool(key, value);

  Future<void> setDouble(String key, double value) =>
      _prefs!.setDouble(key, value);
}
