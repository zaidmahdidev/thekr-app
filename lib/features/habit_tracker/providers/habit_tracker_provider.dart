import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

class HabitTrackerState {
  final int currentStreak;
  final int bestStreak;

  /// Goes up with every change, so the screens read the days again.
  final int revision;

  const HabitTrackerState({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.revision = 0,
  });

  HabitTrackerState copyWith({
    int? currentStreak,
    int? bestStreak,
    int? revision,
  }) {
    return HabitTrackerState(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      revision: revision ?? this.revision,
    );
  }
}

class HabitTrackerNotifier extends StateNotifier<HabitTrackerState> {
  static const String _keyPrefix = 'habit_';
  static const String _bestKey = 'habitBestStreak';

  HabitTrackerNotifier() : super(const HabitTrackerState()) {
    final streak = _calculateStreak();
    final savedBest = CacheHelper.getData(key: _bestKey) as int? ?? 0;
    final best = streak > savedBest ? streak : savedBest;
    if (best != savedBest) CacheHelper.saveData(key: _bestKey, value: best);
    state = HabitTrackerState(currentStreak: streak, bestStreak: best);
  }

  // ---------------------------------------------------------------- storage

  /// What was saved for [date] (nothing ticked if nothing was saved).
  DailyHabit habitFor(DateTime date) {
    final dateStr = DailyHabit.formatDate(date);
    final saved = CacheHelper.getData(key: '$_keyPrefix$dateStr');
    if (saved is String) {
      try {
        return DailyHabit.fromJson(saved);
      } catch (_) {}
    }
    return DailyHabit(dateStr: dateStr);
  }

  // ----------------------------------------------------------------- streak

  /// Consecutive days with all five prayers. Today does not break the streak
  /// until the day ends.
  int _calculateStreak() {
    int streak = 0;
    DateTime date = DateTime.now();
    if (!habitFor(date).isFardComplete) {
      date = date.subtract(const Duration(days: 1));
    }
    while (habitFor(date).isFardComplete) {
      streak++;
      date = DateTime(date.year, date.month, date.day - 1);
    }
    return streak;
  }

  // ---------------------------------------------------------------- actions

  /// Ticks or un-ticks one box of [date].
  Future<void> toggle(DateTime date, HabitField field) async {
    if (DateUtils.dateOnly(date).isAfter(DateUtils.dateOnly(DateTime.now()))) {
      return; // the days to come are not recorded in advance
    }
    final current = habitFor(date);
    final updated = current.withField(field, !current.isDone(field));

    await CacheHelper.saveData(
      key: '$_keyPrefix${updated.dateStr}',
      value: updated.toJson(),
    );

    final streak = _calculateStreak();
    final best = streak > state.bestStreak ? streak : state.bestStreak;
    if (best != state.bestStreak) {
      await CacheHelper.saveData(key: _bestKey, value: best);
    }
    state = state.copyWith(
      currentStreak: streak,
      bestStreak: best,
      revision: state.revision + 1,
    );
  }
}

final habitTrackerProvider =
    StateNotifierProvider<HabitTrackerNotifier, HabitTrackerState>((ref) {
      return HabitTrackerNotifier();
    });
