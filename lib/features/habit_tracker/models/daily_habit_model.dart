import 'dart:convert';
import 'package:intl/intl.dart';

class DailyHabit {
  final String dateStr; // e.g., '2026-08-27'
  
  // Fard Prayers
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  
  // Sunnah & Nawafil
  final bool qiyam;
  final bool rawatib; 
  
  // Azkar & Quran
  final bool morningAzkar;
  final bool eveningAzkar;
  final bool quranWird;

  DailyHabit({
    required this.dateStr,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.qiyam = false,
    this.rawatib = false,
    this.morningAzkar = false,
    this.eveningAzkar = false,
    this.quranWird = false,
  });

  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    if (qiyam) count++;
    if (rawatib) count++;
    if (morningAzkar) count++;
    if (eveningAzkar) count++;
    if (quranWird) count++;
    return count;
  }

  int get totalHabits => 10;
  
  double get progress => completedCount / totalHabits;

  int get totalPoints {
    int points = 0;
    // Fard
    if (fajr) points += 10;
    if (dhuhr) points += 10;
    if (asr) points += 10;
    if (maghrib) points += 10;
    if (isha) points += 10;
    // Sunnah
    if (qiyam) points += 15;
    if (rawatib) points += 15;
    // Azkar
    if (morningAzkar) points += 10;
    if (eveningAzkar) points += 10;
    if (quranWird) points += 10;
    
    // Perfect Day Bonus
    if (progress >= 1.0) points += 40;
    
    return points;
  }

  DailyHabit copyWith({
    String? dateStr,
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    bool? qiyam,
    bool? rawatib,
    bool? morningAzkar,
    bool? eveningAzkar,
    bool? quranWird,
  }) {
    return DailyHabit(
      dateStr: dateStr ?? this.dateStr,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      qiyam: qiyam ?? this.qiyam,
      rawatib: rawatib ?? this.rawatib,
      morningAzkar: morningAzkar ?? this.morningAzkar,
      eveningAzkar: eveningAzkar ?? this.eveningAzkar,
      quranWird: quranWird ?? this.quranWird,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateStr': dateStr,
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'qiyam': qiyam,
      'rawatib': rawatib,
      'morningAzkar': morningAzkar,
      'eveningAzkar': eveningAzkar,
      'quranWird': quranWird,
    };
  }

  factory DailyHabit.fromMap(Map<String, dynamic> map) {
    return DailyHabit(
      dateStr: map['dateStr'] ?? '',
      fajr: map['fajr'] ?? false,
      dhuhr: map['dhuhr'] ?? false,
      asr: map['asr'] ?? false,
      maghrib: map['maghrib'] ?? false,
      isha: map['isha'] ?? false,
      qiyam: map['qiyam'] ?? false,
      rawatib: map['rawatib'] ?? false,
      morningAzkar: map['morningAzkar'] ?? false,
      eveningAzkar: map['eveningAzkar'] ?? false,
      quranWird: map['quranWird'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyHabit.fromJson(String source) => DailyHabit.fromMap(json.decode(source));

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
