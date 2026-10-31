import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/core/services/notification_service.dart';
import 'package:thekr_app/core/utils/constants/app_constants.dart';
import 'package:thekr_app/features/account/providers/account_provider.dart';
import 'package:thekr_app/features/account/services/account_service.dart';
import 'package:thekr_app/features/azkar/providers/user_azkar_provider.dart';
import 'package:thekr_app/features/habit_tracker/providers/habit_tracker_provider.dart';
import 'package:thekr_app/features/hajj/providers/hajj_providers.dart';
import 'package:thekr_app/features/home/providers/prayer_provider.dart';
import 'package:thekr_app/features/misbaha/providers/misbaha_provider.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_calc_provider.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';
import 'package:thekr_app/features/quran/providers/quran_provider.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:thekr_app/features/radio/providers/radio_providers.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/features/settings/providers/share_card_style_provider.dart';
import 'package:thekr_app/features/umrah/providers/umrah_checklist_provider.dart';
import '../services/cloud_sync_service.dart';
import '../services/snapshot_service.dart';
import '../services/sync_store.dart';

enum SyncPhase { idle, syncing, failed }

class SyncState {
  final SyncPhase phase;
  final DateTime? lastSyncAt;
  final bool autoSync;

  const SyncState({
    this.phase = SyncPhase.idle,
    this.lastSyncAt,
    this.autoSync = true,
  });

  bool get isSyncing => phase == SyncPhase.syncing;

  SyncState copyWith({
    SyncPhase? phase,
    DateTime? lastSyncAt,
    bool? autoSync,
  }) => SyncState(
    phase: phase ?? this.phase,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    autoSync: autoSync ?? this.autoSync,
  );
}

/// Keeps the phone and the account in step. The phone's own data is always the
/// working copy; the account is a backup that is merged in, never the source
/// the app reads from.
class SyncController extends StateNotifier<SyncState> {
  SyncController(this._ref) : super(_initial()) {
    // Syncs once when the user signs in, and once at start when already
    // signed in.
    _ref.listen(accountUserProvider, (prev, next) {
      final was = prev?.value?.uid;
      final now = next.value?.uid;
      if (now != null && now != was && state.autoSync) {
        syncNow();
      }
    }, fireImmediately: true);
  }

  final Ref _ref;
  bool _running = false;

  static const String _lastSyncKey = 'sync_last_at';
  static const String _autoKey = 'sync_auto';
  static const String _preRestoreKey = 'sync_pre_restore';

  /// Automatic syncs are spaced out so opening and closing the app quickly
  /// does not write to the account each time.
  static const Duration autoInterval = Duration(minutes: 3);

  /// Without internet Firestore does not fail, it waits. The sync gives up
  /// after this long, so the screen never says "saving" for ever.
  static const Duration networkTimeout = Duration(seconds: 20);

  static SyncState _initial() {
    final last = CacheHelper.getData(key: _lastSyncKey);
    final auto = CacheHelper.getData(key: _autoKey);
    return SyncState(
      lastSyncAt: last is int ? DateTime.fromMillisecondsSinceEpoch(last) : null,
      autoSync: auto is bool ? auto : true,
    );
  }

  void setAutoSync(bool value) {
    CacheHelper.saveData(key: _autoKey, value: value);
    state = state.copyWith(autoSync: value);
    if (value) syncNow();
  }

  /// Called when the app goes to the background or comes back.
  Future<void> syncIfDue() async {
    if (!state.autoSync) return;
    final last = state.lastSyncAt;
    if (last != null && DateTime.now().difference(last) < autoInterval) return;
    await syncNow();
  }

  Future<void> syncNow() async {
    final user = AccountService.instance.currentUser;
    if (user == null || _running) return;
    _running = true;
    state = state.copyWith(phase: SyncPhase.syncing);

    try {
      const store = CacheSyncStore();
      final service = SnapshotService(store, SyncMeta(store));
      final cloud = CloudSyncService();

      final bookmarksBefore = QuranReaderAdapter.bookmarksForSync();
      final local = service.build(bookmarks: bookmarksBefore);
      final remote =
          await cloud.download(user.uid).timeout(networkTimeout);

      final merged = remote == null
          ? local
          : service.mergeWith(remote, bookmarks: bookmarksBefore);

      if (remote != null) {
        // A copy of what the phone had, in case a merge is not what the user
        // wanted. Kept locally only.
        await store.write(_preRestoreKey, json.encode(local.toJson()));
      }

      final result = await service.apply(merged);
      final bookmarkKeysBefore = {for (final b in bookmarksBefore) b.key};
      if (!_sameKeys(bookmarkKeysBefore, merged.bookmarks.keys.toSet())) {
        QuranReaderAdapter.loadSyncedBookmarks(merged.bookmarks.values);
      }

      await cloud.upload(user.uid, merged).timeout(networkTimeout);
      // The readable profile is a nice-to-have: failing to write it must not
      // fail the backup that already succeeded.
      try {
        await cloud
            .saveProfile(
              user,
              location: merged.location,
              appVersion: AppConstants.appVersion,
            )
            .timeout(networkTimeout);
      } catch (_) {}

      final now = DateTime.now();
      await CacheHelper.saveData(
        key: _lastSyncKey,
        value: now.millisecondsSinceEpoch,
      );
      if (!result.isEmpty) _refreshApp();
      state = state.copyWith(phase: SyncPhase.idle, lastSyncAt: now);
    } catch (_) {
      state = state.copyWith(phase: SyncPhase.failed);
    } finally {
      _running = false;
    }
  }

  bool _sameKeys(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  /// Makes what is on screen follow the data that was just restored.
  void _refreshApp() {
    _ref.invalidate(settingsProvider);
    _ref.invalidate(userAzkarProvider);
    _ref.invalidate(habitTrackerProvider);
    _ref.invalidate(misbahaProvider);
    _ref.invalidate(radioFavoritesProvider);
    _ref.invalidate(umrahChecklistProvider);
    _ref.invalidate(hajjChecklistProvider);
    _ref.invalidate(shareCardStyleProvider);
    _ref.invalidate(quranProvider);
    _ref.invalidate(prayerCalcProvider);
    _ref.invalidate(prayerTimesProvider);
    _ref.invalidate(tomorrowPrayerTimesProvider);
    _ref.invalidate(prayerLocationProvider);
    // Restored reminder times need new alarms.
    NotificationService.refreshScheduledNotifications();
  }

  /// Deletes the account's stored backup, then the account itself.
  Future<bool> deleteAccount() async {
    final user = AccountService.instance.currentUser;
    if (user == null) return false;
    try {
      await CloudSyncService().deleteAll(user.uid);
    } catch (_) {
      return false;
    }
    return AccountService.instance.deleteAccount();
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>(SyncController.new);
