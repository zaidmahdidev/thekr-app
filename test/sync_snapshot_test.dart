import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:thekr_app/features/sync/models/sync_snapshot.dart';
import 'package:thekr_app/features/sync/services/snapshot_service.dart';
import 'package:thekr_app/features/sync/services/sync_merger.dart';
import 'package:thekr_app/features/sync/services/sync_rules.dart';
import 'package:thekr_app/features/sync/services/sync_store.dart';

class MemoryStore implements SyncStore {
  final Map<String, Object> data = {};

  @override
  Iterable<String> get keys => data.keys.toList();

  @override
  Object? read(String key) => data[key];

  @override
  Future<void> write(String key, Object value) async => data[key] = value;

  @override
  Future<void> remove(String key) async => data.remove(key);
}

const _now = 1000000000000;

SnapshotService _service(MemoryStore store, [int Function()? clock]) =>
    SnapshotService(store, SyncMeta(store, clock: clock ?? () => _now));

void main() {
  group('rules', () {
    test('only listed keys leave the device', () {
      expect(SyncRules.kindOf('fontSize'), SyncKind.latestWins);
      expect(SyncRules.kindOf('misbaha_zikr_subhanallah'), SyncKind.latestWins);
      expect(SyncRules.kindOf('habit_2026-08-27'), SyncKind.habitDay);
      expect(SyncRules.kindOf('habitBestStreak'), SyncKind.maxNumber);
      expect(SyncRules.kindOf('app_open_count'), isNull);
      expect(SyncRules.kindOf('last_review_date'), isNull);
      expect(SyncRules.kindOf('clicks_radio'), isNull);
      expect(SyncRules.kindOf('totalAllTimePoints'), isNull);
    });
  });

  group('json', () {
    test('round trip keeps types', () {
      final snap = SyncSnapshot(
        entries: {
          'fontSize': const SyncEntry(18.0, 5),
          'pageNumber': const SyncEntry(77, 6),
          'themeMode': const SyncEntry('dark', 7),
          'notificationsEnabled': const SyncEntry(false, 8),
          'radio_favorites': const SyncEntry(['a', 'b'], 9),
        },
        bookmarks: {
          const SyncBookmark(
            id: 1,
            colorCode: 2,
            name: 'x',
            ayahId: 3,
            ayahNumber: 4,
            page: 5,
          ).key: const SyncBookmark(
            id: 1,
            colorCode: 2,
            name: 'x',
            ayahId: 3,
            ayahNumber: 4,
            page: 5,
          ),
        },
        deletedBookmarks: const {'9:9:9': 10},
        location: const SyncLocation(
          latitude: 24.713,
          longitude: 46.675,
          city: 'الرياض',
          district: 'العليا',
          at: 11,
        ),
      );
      final back = SyncSnapshot.fromJson(
        json.decode(json.encode(snap.toJson())) as Map<String, dynamic>,
      );
      expect(back.entries['fontSize']!.value, 18.0);
      expect(back.entries['fontSize']!.value, isA<double>());
      expect(back.entries['pageNumber']!.value, isA<int>());
      expect(back.entries['radio_favorites']!.value, ['a', 'b']);
      expect(back.bookmarks.length, 1);
      expect(back.deletedBookmarks['9:9:9'], 10);
      expect(back.location!.city, 'الرياض');
      expect(back.location!.district, 'العليا');
    });

    test('malformed entries are skipped, not fatal', () {
      final back = SyncSnapshot.fromJson({
        'entries': {
          'ok': {'t': 's', 'v': 'x', 'at': 1},
          'bad': {'t': 'i', 'v': 'not a number', 'at': 1},
          'worse': 'nope',
        },
        'bookmarks': ['junk', 5],
        'location': {'lat': 'x'},
      });
      expect(back.entries.keys, ['ok']);
      expect(back.bookmarks, isEmpty);
      expect(back.location, isNull);
    });
  });

  group('merge', () {
    SyncSnapshot snap(Map<String, SyncEntry> e) => SyncSnapshot(entries: e);

    test('latest change wins, a tie keeps the phone', () {
      final local = snap({
        'fontSize': const SyncEntry(20.0, 10),
        'themeMode': const SyncEntry('dark', 5),
        'appTheme': const SyncEntry('desert', 5),
      });
      final remote = snap({
        'fontSize': const SyncEntry(16.0, 5),
        'themeMode': const SyncEntry('light', 9),
        'appTheme': const SyncEntry('forest', 5),
      });
      final m = SyncMerger.merge(local, remote, nowMs: _now);
      expect(m.entries['fontSize']!.value, 20.0);
      expect(m.entries['themeMode']!.value, 'light');
      expect(m.entries['appTheme']!.value, 'desert');
    });

    test('keys on one side only are kept', () {
      final m = SyncMerger.merge(
        snap({'pageNumber': const SyncEntry(5, 1)}),
        snap({'fontSize': const SyncEntry(18.0, 1)}),
        nowMs: _now,
      );
      expect(m.entries.keys.toSet(), {'pageNumber', 'fontSize'});
    });

    test('best streak never goes down', () {
      final m = SyncMerger.merge(
        snap({'habitBestStreak': const SyncEntry(9, 100)}),
        snap({'habitBestStreak': const SyncEntry(30, 1)}),
        nowMs: _now,
      );
      expect(m.entries['habitBestStreak']!.value, 30);
    });

    test('a habit day keeps ticks from both sides', () {
      final a = json.encode({'dateStr': 'd', 'fajr': true, 'isha': false});
      final b = json.encode({'dateStr': 'd', 'fajr': false, 'isha': true});
      final m = SyncMerger.merge(
        snap({'habit_d': SyncEntry(a, 0)}),
        snap({'habit_d': SyncEntry(b, 0)}),
        nowMs: _now,
      );
      final day = json.decode(m.entries['habit_d']!.value as String) as Map;
      expect(day['fajr'], true);
      expect(day['isha'], true);
      expect(day['dateStr'], 'd');
    });

    test('bookmarks are united and deletions stick', () {
      const kept = SyncBookmark(
        id: 1, colorCode: 1, name: 'a', ayahId: 10, ayahNumber: 1, page: 1);
      const remoteOnly = SyncBookmark(
        id: 2, colorCode: 1, name: 'b', ayahId: 20, ayahNumber: 2, page: 2);
      const deletedHere = SyncBookmark(
        id: 3, colorCode: 1, name: 'c', ayahId: 30, ayahNumber: 3, page: 3);

      final local = SyncSnapshot(
        bookmarks: {kept.key: kept},
        deletedBookmarks: {deletedHere.key: _now - 10},
      );
      final remote = SyncSnapshot(
        bookmarks: {remoteOnly.key: remoteOnly, deletedHere.key: deletedHere},
      );
      final m = SyncMerger.merge(local, remote, nowMs: _now);
      expect(m.bookmarks.keys.toSet(), {kept.key, remoteOnly.key});
      expect(m.deletedBookmarks.containsKey(deletedHere.key), true);
    });

    test('old deletions are forgotten', () {
      final old = _now - SyncMerger.tombstoneLifetime.inMilliseconds - 1;
      final m = SyncMerger.merge(
        SyncSnapshot(deletedBookmarks: {'x': old}),
        const SyncSnapshot(),
        nowMs: _now,
      );
      expect(m.deletedBookmarks, isEmpty);
    });

    test('location: the account only fills a missing or older place', () {
      const mine = SyncLocation(latitude: 1, longitude: 1, at: 50);
      const theirs = SyncLocation(latitude: 2, longitude: 2, at: 10);
      expect(
        SyncMerger.merge(
          const SyncSnapshot(location: mine),
          const SyncSnapshot(location: theirs),
          nowMs: _now,
        ).location!.latitude,
        1,
      );
      expect(
        SyncMerger.merge(
          const SyncSnapshot(),
          const SyncSnapshot(location: theirs),
          nowMs: _now,
        ).location!.latitude,
        2,
      );
    });
  });

  group('snapshot service', () {
    test('build takes only listed keys and rounds the coordinates', () async {
      final store = MemoryStore()
        ..data['fontSize'] = 20.0
        ..data['app_open_count'] = 40
        ..data['clicks_radio'] = 3
        ..data[SyncRules.latKey] = 24.71355555
        ..data[SyncRules.lngKey] = 46.67529999
        ..data[SyncRules.cityKey] = 'الرياض'
        ..data[SyncRules.districtKey] = 'العليا';
      final svc = _service(store);
      await svc.meta.touch('fontSize', at: 7);
      await svc.meta.touch(SyncRules.latKey, at: 8);

      final snap = svc.build();
      expect(snap.entries.keys, ['fontSize']);
      expect(snap.entries['fontSize']!.at, 7);
      expect(snap.location!.latitude, 24.714);
      expect(snap.location!.longitude, 46.675);
      expect(snap.location!.city, 'الرياض');
      expect(snap.location!.district, 'العليا');
      expect(snap.location!.at, 8);
    });

    test('no saved location means none is uploaded', () {
      final store = MemoryStore()..data['fontSize'] = 20.0;
      expect(_service(store).build().location, isNull);
    });

    test('apply writes values, stamps them, ignores unknown keys', () async {
      final store = MemoryStore();
      final svc = _service(store);
      final result = await svc.apply(
        SyncSnapshot(
          entries: {
            'fontSize': const SyncEntry(22.0, 42),
            'radio_favorites': const SyncEntry(['x'], 43),
            'first_install_version': const SyncEntry('9.9.9', 44),
            'sync_meta': const SyncEntry('{}', 45),
          },
          location: const SyncLocation(
            latitude: 21.4,
            longitude: 39.8,
            city: 'مكة',
            at: 46,
          ),
        ),
      );
      expect(store.data['fontSize'], 22.0);
      expect(store.data['radio_favorites'], ['x']);
      expect(store.data.containsKey('first_install_version'), false);
      expect(svc.meta.modifiedAt('fontSize'), 42);
      expect(svc.meta.modifiedAt(SyncRules.latKey), 46);
      expect(store.data[SyncRules.latKey], 21.4);
      expect(store.data[SyncRules.cityKey], 'مكة');
      expect(store.data.containsKey(SyncRules.districtKey), false);
      expect(result.locationChanged, true);
      expect(result.changedKeys, {'fontSize', 'radio_favorites'});
    });

    test('apply does not replace a newer place on the phone', () async {
      final store = MemoryStore()
        ..data[SyncRules.latKey] = 24.0
        ..data[SyncRules.lngKey] = 46.0;
      final svc = _service(store);
      await svc.meta.touch(SyncRules.latKey, at: 100);
      final result = await svc.apply(
        const SyncSnapshot(
          location: SyncLocation(latitude: 1, longitude: 1, at: 50),
        ),
      );
      expect(store.data[SyncRules.latKey], 24.0);
      expect(result.locationChanged, false);
    });

    test('backup then restore on a fresh phone gives the same data', () async {
      final a = MemoryStore()
        ..data['themeMode'] = 'dark'
        ..data['pageNumber'] = 120
        ..data['umrah_checklist'] = ['passport', 'visa']
        ..data['habit_2026-01-01'] = json.encode({'fajr': true})
        ..data['habitBestStreak'] = 12
        ..data[SyncRules.latKey] = 24.713
        ..data[SyncRules.lngKey] = 46.675;
      final phoneA = _service(a);
      final uploaded = SyncSnapshot.fromJson(
        json.decode(json.encode(phoneA.build().toJson()))
            as Map<String, dynamic>,
      );

      final b = MemoryStore();
      final phoneB = _service(b);
      final merged = phoneB.mergeWith(uploaded, nowMs: _now);
      await phoneB.apply(merged);

      expect(b.data['themeMode'], 'dark');
      expect(b.data['pageNumber'], 120);
      expect(b.data['umrah_checklist'], ['passport', 'visa']);
      expect(b.data['habitBestStreak'], 12);
      expect(b.data['habit_2026-01-01'], isA<String>());
      expect(b.data[SyncRules.latKey], 24.713);
    });
  });
}
