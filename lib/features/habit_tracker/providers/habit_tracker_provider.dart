import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

class HabitTrackerState {
  final DateTime selectedDate;
  final DailyHabit habit;
  final int currentStreak;
  final int bestStreak;
  final int totalAllTimePoints;

  /// Completion (0..1) of the last [HabitTrackerNotifier.historyDays] days,
  /// oldest first, today last.
  final List<double> recentProgress;

  const HabitTrackerState({
    required this.selectedDate,
    required this.habit,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalAllTimePoints = 0,
    this.recentProgress = const [],
  });

  /// Average completion of the last 7 days (0..1).
  double get weeklyAverage {
    if (recentProgress.isEmpty) return 0;
    final week = recentProgress.length > 7
        ? recentProgress.sublist(recentProgress.length - 7)
        : recentProgress;
    return week.fold<double>(0, (a, b) => a + b) / week.length;
  }

  HabitTrackerState copyWith({
    DateTime? selectedDate,
    DailyHabit? habit,
    int? currentStreak,
    int? bestStreak,
    int? totalAllTimePoints,
    List<double>? recentProgress,
  }) {
    return HabitTrackerState(
      selectedDate: selectedDate ?? this.selectedDate,
      habit: habit ?? this.habit,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalAllTimePoints: totalAllTimePoints ?? this.totalAllTimePoints,
      recentProgress: recentProgress ?? this.recentProgress,
    );
  }
}

class HabitTrackerNotifier extends StateNotifier<HabitTrackerState> {
  static const int historyDays = 31;
  static const String _keyPrefix = 'habit_';
  static const String _totalKey = 'totalAllTimePoints';
  static const String _bestKey = 'habitBestStreak';

  HabitTrackerNotifier()
    : super(
        HabitTrackerState(
          selectedDate: DateTime.now(),
          habit: DailyHabit(dateStr: DailyHabit.formatDate(DateTime.now())),
        ),
      ) {
    final today = DateTime.now();
    final streak = _calculateStreak();
    final savedBest = CacheHelper.getData(key: _bestKey) as int? ?? 0;
    final best = streak > savedBest ? streak : savedBest;
    if (best != savedBest) CacheHelper.saveData(key: _bestKey, value: best);

    state = state.copyWith(
      selectedDate: today,
      habit: _habitFor(today),
      currentStreak: streak,
      bestStreak: best,
      totalAllTimePoints: _recomputeTotalPoints(),
      recentProgress: _recentProgress(),
    );
  }

  // ---------------------------------------------------------------- storage

  DailyHabit _habitFor(DateTime date) {
    final dateStr = DailyHabit.formatDate(date);
    final saved = CacheHelper.getData(key: '$_keyPrefix$dateStr');
    if (saved is String) {
      try {
        return DailyHabit.fromJson(saved);
      } catch (_) {}
    }
    return DailyHabit(dateStr: dateStr);
  }

  /// Sum of the points of every saved day. Recomputed from the saved days so
  /// it is always correct (an earlier version never updated the stored total).
  int _recomputeTotalPoints() {
    int total = 0;
    for (final key in CacheHelper.sharedPreferences.getKeys()) {
      if (!key.startsWith(_keyPrefix)) continue;
      final saved = CacheHelper.getData(key: key);
      if (saved is! String) continue;
      try {
        total += DailyHabit.fromJson(saved).totalPoints;
      } catch (_) {}
    }
    CacheHelper.saveData(key: _totalKey, value: total);
    return total;
  }

  List<double> _recentProgress() {
    final today = DateTime.now();
    return [
      for (int i = historyDays - 1; i >= 0; i--)
        _habitFor(today.subtract(Duration(days: i))).progress,
    ];
  }

  // ----------------------------------------------------------------- streak

  bool _isFardCompleted(DailyHabit habit) =>
      habit.fajr && habit.dhuhr && habit.asr && habit.maghrib && habit.isha;

  /// Consecutive days with all five prayers. Today does not break the streak
  /// until the day ends.
  int _calculateStreak() {
    int streak = 0;
    DateTime date = DateTime.now();
    if (!_isFardCompleted(_habitFor(date))) {
      date = date.subtract(const Duration(days: 1));
    }
    while (_isFardCompleted(_habitFor(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ---------------------------------------------------------------- actions

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date, habit: _habitFor(date));
  }

  Future<void> _save(DailyHabit updated) async {
    final oldPoints = state.habit.totalPoints;
    // Show the change immediately, then persist and refresh the statistics.
    state = state.copyWith(habit: updated);

    await CacheHelper.saveData(
      key: '$_keyPrefix${updated.dateStr}',
      value: updated.toJson(),
    );

    final streak = _calculateStreak();
    final best = streak > state.bestStreak ? streak : state.bestStreak;
    final total = state.totalAllTimePoints + (updated.totalPoints - oldPoints);

    await CacheHelper.saveData(key: _totalKey, value: total);
    if (best != state.bestStreak) {
      await CacheHelper.saveData(key: _bestKey, value: best);
    }

    state = state.copyWith(
      currentStreak: streak,
      bestStreak: best,
      totalAllTimePoints: total,
      recentProgress: _recentProgress(),
    );
  }

  void toggleFajr() => _save(state.habit.copyWith(fajr: !state.habit.fajr));
  void toggleDhuhr() => _save(state.habit.copyWith(dhuhr: !state.habit.dhuhr));
  void toggleAsr() => _save(state.habit.copyWith(asr: !state.habit.asr));
  void toggleMaghrib() =>
      _save(state.habit.copyWith(maghrib: !state.habit.maghrib));
  void toggleIsha() => _save(state.habit.copyWith(isha: !state.habit.isha));

  void toggleQiyam() => _save(state.habit.copyWith(qiyam: !state.habit.qiyam));
  void toggleRawatib() =>
      _save(state.habit.copyWith(rawatib: !state.habit.rawatib));

  void toggleMorningAzkar() =>
      _save(state.habit.copyWith(morningAzkar: !state.habit.morningAzkar));
  void toggleEveningAzkar() =>
      _save(state.habit.copyWith(eveningAzkar: !state.habit.eveningAzkar));
  void toggleQuranWird() =>
      _save(state.habit.copyWith(quranWird: !state.habit.quranWird));
}

final habitTrackerProvider =
    StateNotifierProvider<HabitTrackerNotifier, HabitTrackerState>((ref) {
      return HabitTrackerNotifier();
    });
