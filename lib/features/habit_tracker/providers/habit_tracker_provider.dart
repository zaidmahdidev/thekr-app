import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/habit_tracker/models/daily_habit_model.dart';

class HabitTrackerState {
  final DateTime selectedDate;
  final DailyHabit habit;
  final int currentStreak;
  final int totalAllTimePoints;

  HabitTrackerState({
    required this.selectedDate,
    required this.habit,
    this.currentStreak = 0,
    this.totalAllTimePoints = 0,
  });

  HabitTrackerState copyWith({
    DateTime? selectedDate,
    DailyHabit? habit,
    int? currentStreak,
    int? totalAllTimePoints,
  }) {
    return HabitTrackerState(
      selectedDate: selectedDate ?? this.selectedDate,
      habit: habit ?? this.habit,
      currentStreak: currentStreak ?? this.currentStreak,
      totalAllTimePoints: totalAllTimePoints ?? this.totalAllTimePoints,
    );
  }
}

class HabitTrackerNotifier extends StateNotifier<HabitTrackerState> {
  HabitTrackerNotifier()
      : super(HabitTrackerState(
          selectedDate: DateTime.now(),
          habit: DailyHabit(dateStr: DailyHabit.formatDate(DateTime.now())),
        )) {
    _loadHabitForDate(state.selectedDate);
    _calculateStreak();
    _loadTotalPoints();
  }

  void _loadTotalPoints() {
    final points = CacheHelper.getData(key: 'totalAllTimePoints') as int? ?? 0;
    state = state.copyWith(totalAllTimePoints: points);
  }

  void selectDate(DateTime date) {
    _loadHabitForDate(date);
  }

  void _calculateStreak() {
    int streak = 0;
    DateTime dateToCheck = DateTime.now();
    
    // Check if today is completed (all Fard prayers)
    DailyHabit todayHabit = _getHabitFromCache(dateToCheck);
    bool isTodayFardCompleted = _isFardCompleted(todayHabit);
    
    // If today is not completed, check if yesterday was. The streak is not broken until the day ends.
    if (!isTodayFardCompleted) {
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    }
    
    while (true) {
      DailyHabit habit = _getHabitFromCache(dateToCheck);
      if (_isFardCompleted(habit)) {
        streak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    state = state.copyWith(currentStreak: streak);
  }

  bool _isFardCompleted(DailyHabit habit) {
    // Only count Fard prayers for the streak
    return habit.fajr && habit.dhuhr && habit.asr && habit.maghrib && habit.isha;
  }

  DailyHabit _getHabitFromCache(DateTime date) {
    final dateStr = DailyHabit.formatDate(date);
    final key = 'habit_$dateStr';
    final savedData = CacheHelper.getData(key: key);
    if (savedData != null && savedData is String) {
      return DailyHabit.fromJson(savedData);
    }
    return DailyHabit(dateStr: dateStr);
  }

  void _loadHabitForDate(DateTime date) {
    final habit = _getHabitFromCache(date);
    state = state.copyWith(selectedDate: date, habit: habit);
  }

  Future<void> _saveHabit(DailyHabit newHabit) async {
    state = state.copyWith(habit: newHabit);
    final key = 'habit_${newHabit.dateStr}';
    await CacheHelper.saveData(key: key, value: newHabit.toJson());
    _calculateStreak();
    
    // Calculate new total points 
    // Optimization: Instead of scanning all days, we just recalculate the total points by adding the difference.
    // Or simpler for now, just load all cached habits points if needed, but since it's local we can just add the difference.
    // Actually, since we only save the *current* habit, we find the diff:
    final int oldPoints = state.habit.totalPoints;
    final int newPoints = newHabit.totalPoints;
    final int diff = newPoints - oldPoints;
    
    final int newTotal = state.totalAllTimePoints + diff;
    await CacheHelper.saveData(key: 'totalAllTimePoints', value: newTotal);
    state = state.copyWith(totalAllTimePoints: newTotal, habit: newHabit);
  }

  // Toggles
  void toggleFajr() => _saveHabit(state.habit.copyWith(fajr: !state.habit.fajr));
  void toggleDhuhr() => _saveHabit(state.habit.copyWith(dhuhr: !state.habit.dhuhr));
  void toggleAsr() => _saveHabit(state.habit.copyWith(asr: !state.habit.asr));
  void toggleMaghrib() => _saveHabit(state.habit.copyWith(maghrib: !state.habit.maghrib));
  void toggleIsha() => _saveHabit(state.habit.copyWith(isha: !state.habit.isha));
  
  void toggleQiyam() => _saveHabit(state.habit.copyWith(qiyam: !state.habit.qiyam));
  void toggleRawatib() => _saveHabit(state.habit.copyWith(rawatib: !state.habit.rawatib));
  
  void toggleMorningAzkar() => _saveHabit(state.habit.copyWith(morningAzkar: !state.habit.morningAzkar));
  void toggleEveningAzkar() => _saveHabit(state.habit.copyWith(eveningAzkar: !state.habit.eveningAzkar));
  void toggleQuranWird() => _saveHabit(state.habit.copyWith(quranWird: !state.habit.quranWird));
}

final habitTrackerProvider = StateNotifierProvider<HabitTrackerNotifier, HabitTrackerState>((ref) {
  return HabitTrackerNotifier();
});
