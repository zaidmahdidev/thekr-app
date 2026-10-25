import 'dart:convert';

import 'package:thekr_app/core/services/cache_helper.dart';

/// The small slice of local storage the sync layer needs. Behind an interface
/// so the logic can be tested without a device.
abstract class SyncStore {
  Iterable<String> get keys;
  Object? read(String key);
  Future<void> write(String key, Object value);
  Future<void> remove(String key);
}

/// The app's real storage ([CacheHelper] / SharedPreferences).
class CacheSyncStore implements SyncStore {
  const CacheSyncStore();

  @override
  Iterable<String> get keys => CacheHelper.sharedPreferences.getKeys();

  @override
  Object? read(String key) => CacheHelper.sharedPreferences.get(key);

  // Straight to SharedPreferences, not through CacheHelper.saveData, so that
  // applying a restore does not stamp every key as "changed just now".
  @override
  Future<void> write(String key, Object value) async {
    final prefs = CacheHelper.sharedPreferences;
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  @override
  Future<void> remove(String key) async {
    await CacheHelper.sharedPreferences.remove(key);
  }
}

/// Remembers when each synced key last changed on this phone.
///
/// Stored as one small JSON map. [install] hooks [CacheHelper] so every normal
/// save is stamped without touching the screens and providers that save.
class SyncMeta {
  static const String storageKey = 'sync_meta';
  static const String tombstoneKey = 'sync_bookmark_tombstones';

  final SyncStore store;
  final int Function() clock;

  SyncMeta(this.store, {int Function()? clock})
    : clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  Map<String, int>? _cache;

  Map<String, int> get _map {
    final cached = _cache;
    if (cached != null) return cached;
    final out = <String, int>{};
    final raw = store.read(storageKey);
    if (raw is String) {
      try {
        for (final e in (json.decode(raw) as Map).entries) {
          if (e.value is num) out[e.key.toString()] = (e.value as num).toInt();
        }
      } catch (_) {}
    }
    return _cache = out;
  }

  int? modifiedAt(String key) => _map[key];

  Future<void> touch(String key, {int? at}) async {
    _map[key] = at ?? clock();
    await _persist();
  }

  Future<void> forget(String key) async {
    if (_map.remove(key) != null) await _persist();
  }

  Future<void> setAll(Map<String, int> stamps) async {
    _map.addAll(stamps);
    await _persist();
  }

  Future<void> _persist() => store.write(storageKey, json.encode(_map));

  // ------------------------------------------------------ bookmark deletions

  Map<String, int> get deletedBookmarks {
    final raw = store.read(tombstoneKey);
    final out = <String, int>{};
    if (raw is String) {
      try {
        for (final e in (json.decode(raw) as Map).entries) {
          if (e.value is num) out[e.key.toString()] = (e.value as num).toInt();
        }
      } catch (_) {}
    }
    return out;
  }

  Future<void> recordBookmarkDeleted(String bookmarkKey) async {
    final map = deletedBookmarks..[bookmarkKey] = clock();
    await store.write(tombstoneKey, json.encode(map));
  }

  Future<void> replaceDeletedBookmarks(Map<String, int> map) =>
      store.write(tombstoneKey, json.encode(map));

  // ------------------------------------------------------------------ hook

  /// Stamps every synced key that [CacheHelper] saves from now on.
  ///
  /// Keys saved before this existed have no stamp. They get the current time
  /// once, so on the first sync the phone's own data is treated as current
  /// and is not silently replaced by an older copy from the account.
  static Future<void> install(
    SyncMeta meta,
    bool Function(String) shouldStamp,
  ) async {
    final missing = [
      for (final key in meta.store.keys)
        if (shouldStamp(key) && meta.modifiedAt(key) == null) key,
    ];
    if (missing.isNotEmpty) {
      final now = meta.clock();
      await meta.setAll({for (final key in missing) key: now});
    }
    CacheHelper.onKeyChanged = (key) {
      if (shouldStamp(key)) meta.touch(key);
    };
  }
}
