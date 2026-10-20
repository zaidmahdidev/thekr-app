import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

/// Ticks on a packing list, saved on the device under [storageKey]. Used by
/// both the Umrah and the Hajj lists, which are for getting ready at home.
class ChecklistNotifier extends StateNotifier<Set<String>> {
  ChecklistNotifier(this.storageKey)
    : super(
        ((CacheHelper.getData(key: storageKey) as List<dynamic>?) ?? const [])
            .cast<String>()
            .toSet(),
      );

  final String storageKey;

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    CacheHelper.saveData(key: storageKey, value: next.toList());
  }

  void clear() {
    state = const {};
    CacheHelper.saveData(key: storageKey, value: <String>[]);
  }
}

final umrahChecklistProvider =
    StateNotifierProvider<ChecklistNotifier, Set<String>>(
      (ref) => ChecklistNotifier('umrah_checklist'),
    );
