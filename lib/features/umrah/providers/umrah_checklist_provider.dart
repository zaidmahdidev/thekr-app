import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

/// Ticks on the packing list, saved on the device. The list is for getting
/// ready at home, before the trip.
class UmrahChecklistNotifier extends StateNotifier<Set<String>> {
  UmrahChecklistNotifier()
    : super(
        ((CacheHelper.getData(key: _key) as List<dynamic>?) ?? const [])
            .cast<String>()
            .toSet(),
      );

  static const String _key = 'umrah_checklist';

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    CacheHelper.saveData(key: _key, value: next.toList());
  }

  void clear() {
    state = const {};
    CacheHelper.saveData(key: _key, value: <String>[]);
  }
}

final umrahChecklistProvider =
    StateNotifierProvider<UmrahChecklistNotifier, Set<String>>(
      (ref) => UmrahChecklistNotifier(),
    );
