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

/// How a bead is drawn: grain for wood, glow for gems, bands for metal.
enum BeadMaterial { wood, gem, metal }

/// Bead looks: [colors] are the highlight, body and shadow tones (the colors
/// are artwork, not UI colors, so they are fixed).
enum BeadType {
  wood('خشبي', [
    Color(0xFFC9895F),
    Color(0xFF7A4A2B),
    Color(0xFF2B1810),
  ], BeadMaterial.wood),
  amber('كهرماني', [
    Color(0xFFFFC857),
    Color(0xFFD98A12),
    Color(0xFF6B3A05),
  ], BeadMaterial.gem),
  emerald('زمردي', [
    Color(0xFF6FE3A1),
    Color(0xFF0FA566),
    Color(0xFF023B35),
  ], BeadMaterial.gem),
  ruby('ياقوتي', [
    Color(0xFFFF4F86),
    Color(0xFFB3123A),
    Color(0xFF45030F),
  ], BeadMaterial.gem),
  onyx('عقيق أسود', [
    Color(0xFF6B6F7A),
    Color(0xFF23252C),
    Color(0xFF05060A),
  ], BeadMaterial.gem),
  silver('فضي', [
    Color(0xFFF2F2F4),
    Color(0xFFA7A9B0),
    Color(0xFF3A3C42),
  ], BeadMaterial.metal);

  final String label;
  final List<Color> colors;
  final BeadMaterial material;
  const BeadType(this.label, this.colors, this.material);
}

/// Round sizes offered in the target picker (0 = no target).
const List<int> misbahaTargets = [33, 99, 100, 0];

class MisbahaState {
  final int count;
  final int totalCount;
  final MisbahaZikr currentZikr;
  final Map<MisbahaZikr, int> zikrCounts;
  final BeadType beadType;

  /// Count that makes one round (0 = no target).
  final int target;

  MisbahaState({
    this.count = 0,
    this.totalCount = 0,
    this.currentZikr = MisbahaZikr.subhanAllah,
    this.zikrCounts = const {},
    this.beadType = BeadType.wood,
    this.target = 33,
  });

  MisbahaState copyWith({
    int? count,
    int? totalCount,
    MisbahaZikr? currentZikr,
    Map<MisbahaZikr, int>? zikrCounts,
    BeadType? beadType,
    int? target,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
      currentZikr: currentZikr ?? this.currentZikr,
      zikrCounts: zikrCounts ?? this.zikrCounts,
      beadType: beadType ?? this.beadType,
      target: target ?? this.target,
    );
  }
}
