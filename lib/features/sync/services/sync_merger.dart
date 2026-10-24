import 'dart:convert';

import '../models/sync_snapshot.dart';
import 'sync_rules.dart';

/// Combines what is on the phone with what is in the account. Pure functions,
/// so every rule is covered by a unit test.
class SyncMerger {
  SyncMerger._();

  /// Deletions older than this are forgotten so the list stays small.
  static const Duration tombstoneLifetime = Duration(days: 90);

  static SyncSnapshot merge(
    SyncSnapshot local,
    SyncSnapshot remote, {
    required int nowMs,
  }) {
    return SyncSnapshot(
      entries: _mergeEntries(local.entries, remote.entries),
      bookmarks: _mergeBookmarks(local, remote, nowMs),
      deletedBookmarks: _mergeTombstones(local, remote, nowMs),
      location: _mergeLocation(local.location, remote.location),
    );
  }

  static Map<String, SyncEntry> _mergeEntries(
    Map<String, SyncEntry> local,
    Map<String, SyncEntry> remote,
  ) {
    final merged = <String, SyncEntry>{};
    for (final key in {...local.keys, ...remote.keys}) {
      final l = local[key];
      final r = remote[key];
      if (l == null) {
        merged[key] = r!;
        continue;
      }
      if (r == null) {
        merged[key] = l;
        continue;
      }
      switch (SyncRules.kindOf(key)) {
        case SyncKind.maxNumber:
          merged[key] = _maxOf(l, r);
        case SyncKind.habitDay:
          merged[key] = _mergeHabitDay(l, r);
        case SyncKind.latestWins:
        case null:
          // A tie keeps the phone's value, so a restore never rewrites
          // something that did not change.
          merged[key] = r.at > l.at ? r : l;
      }
    }
    return merged;
  }

  static SyncEntry _maxOf(SyncEntry a, SyncEntry b) {
    final av = a.value;
    final bv = b.value;
    if (av is num && bv is num) return bv > av ? b : a;
    return b.at > a.at ? b : a;
  }

  /// A habit day is a JSON string of booleans. Anything ticked on either side
  /// stays ticked.
  static SyncEntry _mergeHabitDay(SyncEntry a, SyncEntry b) {
    final av = a.value;
    final bv = b.value;
    if (av is! String || bv is! String) return b.at > a.at ? b : a;
    try {
      final am = Map<String, dynamic>.from(json.decode(av) as Map);
      final bm = Map<String, dynamic>.from(json.decode(bv) as Map);
      final out = <String, dynamic>{};
      for (final key in {...am.keys, ...bm.keys}) {
        final x = am[key];
        final y = bm[key];
        if (x is bool || y is bool) {
          out[key] = (x == true) || (y == true);
        } else {
          out[key] = x ?? y;
        }
      }
      return SyncEntry(json.encode(out), a.at > b.at ? a.at : b.at);
    } catch (_) {
      return b.at > a.at ? b : a;
    }
  }

  static Map<String, SyncBookmark> _mergeBookmarks(
    SyncSnapshot local,
    SyncSnapshot remote,
    int nowMs,
  ) {
    final deleted = _mergeTombstones(local, remote, nowMs);
    final merged = <String, SyncBookmark>{};
    for (final b in [...remote.bookmarks.values, ...local.bookmarks.values]) {
      if (deleted.containsKey(b.key)) continue;
      merged[b.key] = b;
    }
    return merged;
  }

  static Map<String, int> _mergeTombstones(
    SyncSnapshot local,
    SyncSnapshot remote,
    int nowMs,
  ) {
    final cutoff = nowMs - tombstoneLifetime.inMilliseconds;
    final out = <String, int>{};
    for (final source in [local.deletedBookmarks, remote.deletedBookmarks]) {
      for (final e in source.entries) {
        if (e.value < cutoff) continue;
        final current = out[e.key];
        if (current == null || e.value > current) out[e.key] = e.value;
      }
    }
    return out;
  }

  /// The phone's own place wins when it is newer. The account's place is only
  /// used when the phone does not have one yet.
  static SyncLocation? _mergeLocation(SyncLocation? l, SyncLocation? r) {
    if (l == null) return r;
    if (r == null) return l;
    return r.at > l.at ? r : l;
  }
}
