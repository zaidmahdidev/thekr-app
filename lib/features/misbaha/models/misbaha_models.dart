import 'package:thekr_app/features/misbaha/providers/misbaha_provider.dart'; // For MisbahaZikr if needed, but I'll move it here

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
  final Map<MisbahaZikr, int> zikrCounts;

  MisbahaState({
    this.count = 0,
    this.totalCount = 0,
    this.currentZikr = MisbahaZikr.subhanAllah,
    this.zikrCounts = const {},
  });

  MisbahaState copyWith({
    int? count,
    int? totalCount,
    MisbahaZikr? currentZikr,
    Map<MisbahaZikr, int>? zikrCounts,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
      currentZikr: currentZikr ?? this.currentZikr,
      zikrCounts: zikrCounts ?? this.zikrCounts,
    );
  }
}
