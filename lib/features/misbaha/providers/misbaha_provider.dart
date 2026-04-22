import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MisbahaZikr {
  subhanAllah('سبحان الله'),
  alhamdulillah('الحمد لله'),
  allahuAkbar('الله أكبر'),
  laIlahaIllaAllah('لا إله إلا الله'),
  astaghfirullah('أستغفر الله');

  final String label;
  const MisbahaZikr(this.label);
}

class MisbahaState {
  final int count;
  final int totalCount;
  final MisbahaZikr currentZikr;

  MisbahaState({
    this.count = 0,
    this.totalCount = 0,
    this.currentZikr = MisbahaZikr.subhanAllah,
  });

  MisbahaState copyWith({
    int? count,
    int? totalCount,
    MisbahaZikr? currentZikr,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
      currentZikr: currentZikr ?? this.currentZikr,
    );
  }
}

class MisbahaNotifier extends StateNotifier<MisbahaState> {
  MisbahaNotifier() : super(MisbahaState());

  void increment() {
    state = state.copyWith(
      count: state.count + 1,
      totalCount: state.totalCount + 1,
    );
  }

  void reset() {
    state = state.copyWith(count: 0);
  }

  void setZikr(MisbahaZikr zikr) {
    state = state.copyWith(currentZikr: zikr, count: 0);
  }
}

final misbahaProvider = StateNotifierProvider<MisbahaNotifier, MisbahaState>((ref) {
  return MisbahaNotifier();
});
