import 'dart:convert';

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
  static const _targetKey = 'misbaha_target';
  static const _customKey = 'misbaha_custom_azkar';

  /// Loads persisted counts from CacheHelper
  void _loadData() {
    final totalCount = CacheHelper.getData(key: _totalCountKey) ?? 0;
    final savedTarget = CacheHelper.getData(key: _targetKey);
    final beadTypeName =
        CacheHelper.getData(key: _beadTypeKey) ?? BeadType.wood.name;

    final custom = _loadCustom();
    final counts = <String, int>{};
    for (final zikr in [...builtInAzkar, ...custom]) {
      final saved = CacheHelper.getData(key: _zikrCountPrefix + zikr.id);
      counts[zikr.id] = saved is int ? saved : 0;
    }

    // The one on screen may be gone (removed on another phone).
    final current = [...builtInAzkar, ...custom].firstWhere(
      (z) => z == state.currentZikr,
      orElse: () => builtInAzkar.first,
    );

    state = state.copyWith(
      totalCount: totalCount,
      zikrCounts: counts,
      customAzkar: custom,
      currentZikr: current,
      count: counts[current.id] ?? 0,
      target: savedTarget is int && misbahaTargets.contains(savedTarget)
          ? savedTarget
          : 33,
      beadType: BeadType.values.firstWhere(
        (e) => e.name == beadTypeName,
        orElse: () => BeadType.wood,
      ),
    );
  }

  /// The user's own dhikr. The list can come from the backup, so it is
  /// checked again here: the same limits as when it is typed.
  static List<Zikr> _loadCustom() {
    final raw = CacheHelper.getData(key: _customKey);
    if (raw is! String) return const [];
    try {
      final list = json.decode(raw) as List;
      final result = <Zikr>[];
      for (final item in list) {
        if (item is! Map) continue;
        final id = item['id'];
        final label = cleanLabel(item['label']);
        if (id is! String || id.isEmpty || label.isEmpty) continue;
        if (result.any((z) => z.id == id)) continue;
        result.add(Zikr(id, label, isCustom: true));
        if (result.length == maxCustomAzkar) break;
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  /// Trimmed, one line, within [maxCustomZikrLength]. Empty if nothing is left.
  static String cleanLabel(Object? value) {
    if (value is! String) return '';
    final oneLine = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return oneLine.length > maxCustomZikrLength
        ? oneLine.substring(0, maxCustomZikrLength).trim()
        : oneLine;
  }

  void _saveCustom(List<Zikr> list) {
    CacheHelper.saveData(
      key: _customKey,
      value: json.encode([for (final z in list) z.toJson()]),
    );
  }

  /// Persists specific zikr count to CacheHelper
  void _saveZikrCount(Zikr zikr, int value) {
    CacheHelper.saveData(key: _zikrCountPrefix + zikr.id, value: value);
    CacheHelper.saveData(key: _totalCountKey, value: state.totalCount);
  }

  void _saveBeadType(BeadType type) {
    CacheHelper.saveData(key: _beadTypeKey, value: type.name);
  }

  /// Increments the current count and persists it
  void increment() {
    final newCount = state.count + 1;
    final newZikrCounts = Map<String, int>.from(state.zikrCounts);
    newZikrCounts[state.currentZikr.id] = newCount;

    state = state.copyWith(
      count: newCount,
      totalCount: state.totalCount + 1,
      zikrCounts: newZikrCounts,
    );
    _saveZikrCount(state.currentZikr, newCount);
  }

  /// Resets the count for the current Zikr
  void reset() {
    final newZikrCounts = Map<String, int>.from(state.zikrCounts);
    newZikrCounts[state.currentZikr.id] = 0;

    state = state.copyWith(count: 0, zikrCounts: newZikrCounts);
    _saveZikrCount(state.currentZikr, 0);
  }

  /// Switches to a different Zikr and loads its specific count
  void setZikr(Zikr zikr) {
    state = state.copyWith(
      currentZikr: zikr,
      count: state.zikrCounts[zikr.id] ?? 0,
    );
  }

  /// Adds a dhikr the user wrote and switches to it. Returns why it was not
  /// added, or null when it was.
  String? addCustom(String text) {
    final label = cleanLabel(text);
    if (label.isEmpty) return 'اكتب الذكر أولاً';
    if (state.customAzkar.length >= maxCustomAzkar) {
      return 'وصلت إلى الحد الأعلى (${maxCustomAzkar.toString()} أذكار)، احذف ذكراً أولاً';
    }
    if (state.azkar.any((z) => z.label == label)) {
      return 'هذا الذكر موجود بالفعل';
    }
    final zikr = Zikr(
      'c${DateTime.now().millisecondsSinceEpoch}',
      label,
      isCustom: true,
    );
    final list = [...state.customAzkar, zikr];
    _saveCustom(list);
    state = state.copyWith(
      customAzkar: list,
      zikrCounts: {...state.zikrCounts, zikr.id: 0},
      currentZikr: zikr,
      count: 0,
    );
    return null;
  }

  /// Removes one of the user's dhikr and its count.
  void deleteCustom(Zikr zikr) {
    if (!zikr.isCustom) return;
    final list = [
      for (final z in state.customAzkar)
        if (z != zikr) z,
    ];
    _saveCustom(list);
    // The count is zeroed, not erased, so the backup carries the removal too.
    CacheHelper.saveData(key: _zikrCountPrefix + zikr.id, value: 0);
    final counts = Map<String, int>.from(state.zikrCounts)..remove(zikr.id);
    final wasCurrent = state.currentZikr == zikr;
    final next = wasCurrent ? builtInAzkar.first : state.currentZikr;
    state = state.copyWith(
      customAzkar: list,
      zikrCounts: counts,
      currentZikr: next,
      count: counts[next.id] ?? 0,
    );
  }

  /// Sets the round size (0 = no target).
  void setTarget(int target) {
    state = state.copyWith(target: target);
    CacheHelper.saveData(key: _targetKey, value: target);
  }

  /// Updates the bead type/color
  void setBeadType(BeadType type) {
    state = state.copyWith(beadType: type);
    _saveBeadType(type);
  }
}

final misbahaProvider = StateNotifierProvider<MisbahaNotifier, MisbahaState>((
  ref,
) {
  return MisbahaNotifier();
});
