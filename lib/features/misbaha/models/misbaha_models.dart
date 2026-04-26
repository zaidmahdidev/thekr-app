import 'package:flutter/material.dart';

enum MisbahaZikr {
  subhanAllah('سبحان الله'),
  alhamdulillah('الحمد لله'),
  allahuAkbar('الله أكبر'),
  laIlahaIllaAllah('لا إله إلا الله'),
  astaghfirullah('أستغفر الله');

  final String label;
  const MisbahaZikr(this.label);
}

enum BeadType {
  wood('خشبي', [Color(0xFFC17F59), Color(0xFF5D3622), Color(0xFF2B1810)]),
  emerald('زمردي', [Color(0xFF50C878), Color(0xFF00A86B), Color(0xFF004B49)]),
  ruby('ياقوتي', [Color(0xFFE0115F), Color(0xFF9B111E), Color(0xFF4A0404)]),
  silver('فضي', [Color(0xFFE0E0E0), Color(0xFFA0A0A0), Color(0xFF404040)]);

  final String label;
  final List<Color> colors;
  const BeadType(this.label, this.colors);
}

class MisbahaState {
  final int count;
  final int totalCount;
  final MisbahaZikr currentZikr;
  final Map<MisbahaZikr, int> zikrCounts;
  final BeadType beadType;

  MisbahaState({
    this.count = 0,
    this.totalCount = 0,
    this.currentZikr = MisbahaZikr.subhanAllah,
    this.zikrCounts = const {},
    this.beadType = BeadType.wood,
  });

  MisbahaState copyWith({
    int? count,
    int? totalCount,
    MisbahaZikr? currentZikr,
    Map<MisbahaZikr, int>? zikrCounts,
    BeadType? beadType,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
      currentZikr: currentZikr ?? this.currentZikr,
      zikrCounts: zikrCounts ?? this.zikrCounts,
      beadType: beadType ?? this.beadType,
    );
  }
}
