import 'dart:convert';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/azkar/models/user_thikr.dart';

class UserAzkarService {
  static const String _storageKey = 'user_azkar_list';

  static List<UserThikr> loadAthkar() {
    final String? data = CacheHelper.getData(key: _storageKey);
    if (data == null) return [];

    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((e) => UserThikr.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAthkar(List<UserThikr> athkar) async {
    final String encoded = json.encode(athkar.map((e) => e.toMap()).toList());
    await CacheHelper.saveData(key: _storageKey, value: encoded);
  }
}
