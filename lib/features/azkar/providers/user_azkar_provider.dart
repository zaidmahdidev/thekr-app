import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/features/azkar/data/user_azkar_service.dart';
import 'package:thekr_app/features/azkar/models/user_thikr.dart';

final userAzkarProvider = StateNotifierProvider<UserAzkarNotifier, List<UserThikr>>((ref) {
  return UserAzkarNotifier();
});

class UserAzkarNotifier extends StateNotifier<List<UserThikr>> {
  UserAzkarNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = UserAzkarService.loadAthkar();
  }

  Future<void> addThikr(String text, String? description) async {
    final newThikr = UserThikr(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      description: description,
      createdAt: DateTime.now(),
    );
    state = [...state, newThikr];
    await UserAzkarService.saveAthkar(state);
  }

  Future<void> deleteThikr(String id) async {
    state = state.where((thikr) => thikr.id != id).toList();
    await UserAzkarService.saveAthkar(state);
  }

  Future<void> updateThikr(UserThikr updatedThikr) async {
    state = [
      for (final thikr in state)
        if (thikr.id == updatedThikr.id) updatedThikr else thikr
    ];
    await UserAzkarService.saveAthkar(state);
  }
}
