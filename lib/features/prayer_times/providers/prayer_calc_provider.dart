import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/prayer_service.dart';
import 'package:thekr_app/core/utils/enums/prayer_enum.dart';
import 'package:thekr_app/features/home/models/app_prayer_times.dart';
import 'package:thekr_app/features/home/providers/prayer_provider.dart';
import 'package:thekr_app/features/prayer_times/models/prayer_calc_settings.dart';
import 'package:thekr_app/features/prayer_times/providers/prayer_times_providers.dart';

/// The user's calculation choices. Every change is saved, and everything that
/// shows or schedules prayer times is recalculated.
class PrayerCalcNotifier extends StateNotifier<PrayerCalcSettings> {
  PrayerCalcNotifier(this._ref) : super(PrayerCalcSettings.load());

  final Ref _ref;
  Timer? _recalculateTimer;

  /// How long to wait after the last change before the prayer times of the
  /// whole app are recalculated and the athan is scheduled again. The choice is
  /// saved and shown in the preview at once; only this heavy part waits, so
  /// pressing "+" ten times schedules once, not ten times.
  static const Duration recalculateDelay = Duration(milliseconds: 900);

  Future<void> setMethod(PrayerCalcMethod method) =>
      _apply(state.copyWith(method: method));

  Future<void> setMadhab(AsrMadhab madhab) =>
      _apply(state.copyWith(madhab: madhab));

  Future<void> setHighLatitude(HighLatitudeMode mode) =>
      _apply(state.copyWith(highLatitude: mode));

  Future<void> setRamadanIsha(bool value) =>
      _apply(state.copyWith(ramadanIsha: value));

  /// Moves a prayer by [delta] minutes (negative to make it earlier).
  Future<void> adjust(AppPrayer prayer, int delta) => _apply(
    state.withAdjustment(prayer, state.adjustmentOf(prayer) + delta),
  );

  Future<void> reset() => _apply(const PrayerCalcSettings());

  /// Takes the choices again from storage, after a restore from the account.
  void reload() {
    state = PrayerCalcSettings.load();
  }

  Future<void> _apply(PrayerCalcSettings next) async {
    if (!mounted) return;
    state = next;
    await next.save();
    _recalculateTimer?.cancel();
    _recalculateTimer = Timer(recalculateDelay, _recalculate);
  }

  @override
  void dispose() {
    _recalculateTimer?.cancel();
    super.dispose();
  }

  void _recalculate() {
    _ref.invalidate(tomorrowPrayerTimesProvider);
    _ref.invalidate(prayerTimesProvider);
    // Reading it recalculates today's times, which also schedules the athan
    // notifications again with the new times.
    _ref.read(prayerTimesProvider.future).catchError((_) => null);
  }
}

final prayerCalcProvider =
    StateNotifierProvider<PrayerCalcNotifier, PrayerCalcSettings>(
      PrayerCalcNotifier.new,
    );

/// Today's times with the choices on screen, shown live while the user picks.
final prayerCalcPreviewProvider = Provider<AsyncValue<AppPrayerTimes?>>((ref) {
  final settings = ref.watch(prayerCalcProvider);
  return ref.watch(prayerLocationProvider).whenData(
    (location) => location.isKnown
        ? PrayerService.timesFor(DateTime.now(), location, settings: settings)
        : null,
  );
});
