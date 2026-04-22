import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import '../models/misbaha_models.dart';

export '../models/misbaha_models.dart';

class MisbahaNotifier extends StateNotifier<MisbahaState> {
  MisbahaNotifier() : super(MisbahaState()) {
    _loadData();
  }

  static const _totalCountKey = 'misbaha_total_count';
  static const _zikrCountPrefix = 'misbaha_zikr_';
  static const _beadTypeKey = 'misbaha_bead_type';

  /// Loads persisted counts from CacheHelper
  void _loadData() {
    final totalCount = CacheHelper.getData(key: _totalCountKey) ?? 0;
    final beadTypeName = CacheHelper.getData(key: _beadTypeKey) ?? BeadType.wood.name;
    
    final counts = <MisbahaZikr, int>{};
    for (final zikr in MisbahaZikr.values) {
      counts[zikr] = CacheHelper.getData(key: _zikrCountPrefix + zikr.name) ?? 0;
    }

    state = state.copyWith(
      totalCount: totalCount,
      zikrCounts: counts,
      count: counts[state.currentZikr] ?? 0,
      beadType: BeadType.values.firstWhere((e) => e.name == beadTypeName, orElse: () => BeadType.wood),
    );
  }

  /// Persists specific zikr count to CacheHelper
  void _saveZikrCount(MisbahaZikr zikr, int value) {
    CacheHelper.saveData(key: _zikrCountPrefix + zikr.name, value: value);
    CacheHelper.saveData(key: _totalCountKey, value: state.totalCount);
  }

  void _saveBeadType(BeadType type) {
    CacheHelper.saveData(key: _beadTypeKey, value: type.name);
  }

  /// Increments the current count and persists it
  void increment() {
    final newCount = state.count + 1;
    final newZikrCounts = Map<MisbahaZikr, int>.from(state.zikrCounts);
    newZikrCounts[state.currentZikr] = newCount;

    state = state.copyWith(
      count: newCount,
      totalCount: state.totalCount + 1,
      zikrCounts: newZikrCounts,
    );
    _saveZikrCount(state.currentZikr, newCount);
  }

  /// Resets the count for the current Zikr
  void reset() {
    final newZikrCounts = Map<MisbahaZikr, int>.from(state.zikrCounts);
    newZikrCounts[state.currentZikr] = 0;
    
    state = state.copyWith(count: 0, zikrCounts: newZikrCounts);
    _saveZikrCount(state.currentZikr, 0);
  }

  /// Switches to a different Zikr and loads its specific count
  void setZikr(MisbahaZikr zikr) {
    state = state.copyWith(
      currentZikr: zikr,
      count: state.zikrCounts[zikr] ?? 0,
    );
  }

  /// Updates the bead type/color
  void setBeadType(BeadType type) {
    state = state.copyWith(beadType: type);
    _saveBeadType(type);
  }
}

final misbahaProvider = StateNotifierProvider<MisbahaNotifier, MisbahaState>((ref) {
  return MisbahaNotifier();
});
