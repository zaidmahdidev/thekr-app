import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Called after a key is saved or removed. The sync layer uses it to record
  /// when a key last changed, so no screen has to know about syncing.
  static void Function(String key)? onKeyChanged;

  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    final saved = await _write(key, value);
    if (saved) onKeyChanged?.call(key);
    return saved;
  }

  static Future<bool> _write(String key, dynamic value) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is double) return await sharedPreferences.setDouble(key, value);
    if (value is List<String>) {
      return await sharedPreferences.setStringList(key, value);
    }
    return false;
  }

  static Future<bool> removeData({required String key}) async {
    final removed = await sharedPreferences.remove(key);
    if (removed) onKeyChanged?.call(key);
    return removed;
  }
}
