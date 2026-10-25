import '../models/sync_snapshot.dart';
import 'sync_merger.dart';
import 'sync_rules.dart';
import 'sync_store.dart';

/// What applying a snapshot changed, so the app can refresh what it shows.
class SyncApplyResult {
  final Set<String> changedKeys;
  final bool locationChanged;

  const SyncApplyResult({
    required this.changedKeys,
    required this.locationChanged,
  });

  bool get isEmpty => changedKeys.isEmpty && !locationChanged;
}

/// Reads the account-worthy data out of local storage, and writes a merged
/// snapshot back. Quran bookmarks are passed in and out by the caller because
/// they live inside the Quran library, not in our storage.
class SnapshotService {
  final SyncStore store;
  final SyncMeta meta;

  /// Coordinates are rounded to this many decimals before they leave the
  /// phone: about 110 m, which changes prayer times by well under a second.
  static const int coordinateDecimals = 3;

  SnapshotService(this.store, this.meta);

  SyncSnapshot build({List<SyncBookmark> bookmarks = const []}) {
    final entries = <String, SyncEntry>{};
    for (final key in store.keys) {
      final kind = SyncRules.kindOf(key);
      if (kind == null) continue;
      final value = _syncable(store.read(key));
      if (value == null) continue;
      entries[key] = SyncEntry(value, meta.modifiedAt(key) ?? 0);
    }

    return SyncSnapshot(
      entries: entries,
      bookmarks: {for (final b in bookmarks) b.key: b},
      deletedBookmarks: meta.deletedBookmarks,
      location: _readLocation(),
    );
  }

  Future<SyncApplyResult> apply(SyncSnapshot merged) async {
    final changed = <String>{};
    final stamps = <String, int>{};

    for (final e in merged.entries.entries) {
      // Never write a key the rules do not know: a snapshot comes from the
      // network and must not be able to change arbitrary settings.
      if (SyncRules.kindOf(e.key) == null) continue;
      if (_sameValue(store.read(e.key), e.value.value)) {
        if (SyncRules.needsStamp(e.key) && e.value.at > 0) {
          stamps[e.key] = e.value.at;
        }
        continue;
      }
      await store.write(e.key, e.value.value);
      changed.add(e.key);
      if (SyncRules.needsStamp(e.key)) stamps[e.key] = e.value.at;
    }

    final locationChanged = await _applyLocation(merged.location, stamps);
    await meta.replaceDeletedBookmarks(merged.deletedBookmarks);
    if (stamps.isNotEmpty) await meta.setAll(stamps);

    return SyncApplyResult(
      changedKeys: changed,
      locationChanged: locationChanged,
    );
  }

  /// Local build merged with [remote], ready to be uploaded and applied.
  SyncSnapshot mergeWith(
    SyncSnapshot remote, {
    List<SyncBookmark> bookmarks = const [],
    int? nowMs,
  }) {
    return SyncMerger.merge(
      build(bookmarks: bookmarks),
      remote,
      nowMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  // --------------------------------------------------------------- location

  SyncLocation? _readLocation() {
    final lat = store.read(SyncRules.latKey);
    final lng = store.read(SyncRules.lngKey);
    if (lat is! double || lng is! double) return null;
    final city = store.read(SyncRules.cityKey);
    final district = store.read(SyncRules.districtKey);
    return SyncLocation(
      latitude: _round(lat),
      longitude: _round(lng),
      city: city is String && city.isNotEmpty ? city : null,
      district: district is String && district.isNotEmpty ? district : null,
      at: meta.modifiedAt(SyncRules.latKey) ?? 0,
    );
  }

  /// Fills in a place the phone does not have yet, or replaces an older one.
  /// Never asks for the location permission: this only copies saved data.
  Future<bool> _applyLocation(
    SyncLocation? incoming,
    Map<String, int> stamps,
  ) async {
    if (incoming == null) return false;

    final current = _readLocation();
    final isNewer = current == null || incoming.at > current.at;
    if (!isNewer) return false;

    await store.write(SyncRules.latKey, incoming.latitude);
    await store.write(SyncRules.lngKey, incoming.longitude);
    await _writeOrRemove(SyncRules.cityKey, incoming.city);
    await _writeOrRemove(SyncRules.districtKey, incoming.district);
    for (final key in SyncRules.locationKeys) {
      stamps[key] = incoming.at;
    }
    return true;
  }

  Future<void> _writeOrRemove(String key, String? value) =>
      value == null ? store.remove(key) : store.write(key, value);

  double _round(double v) {
    final f = 1.0 * _pow10(coordinateDecimals);
    return (v * f).roundToDouble() / f;
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  // ---------------------------------------------------------------- helpers

  static Object? _syncable(Object? v) {
    if (v is String || v is bool || v is int || v is double) return v;
    if (v is List && v.every((e) => e is String)) {
      return List<String>.from(v);
    }
    return null;
  }

  static bool _sameValue(Object? a, Object? b) {
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    return a == b;
  }
}
