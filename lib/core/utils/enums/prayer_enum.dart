import 'package:adhan/adhan.dart';

enum AppPrayer {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get nameArabic {
    switch (this) {
      case fajr:
        return 'الفجر';
      case sunrise:
        return 'الشروق';
      case dhuhr:
        return 'الظهر';
      case asr:
        return 'العصر';
      case maghrib:
        return 'المغرب';
      case isha:
        return 'العشاء';
    }
  }

  Prayer get adhanPrayer {
    switch (this) {
      case fajr:
        return Prayer.fajr;
      case sunrise:
        return Prayer.sunrise;
      case dhuhr:
        return Prayer.dhuhr;
      case asr:
        return Prayer.asr;
      case maghrib:
        return Prayer.maghrib;
      case isha:
        return Prayer.isha;
    }
  }

  static AppPrayer fromAdhan(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.sunrise:
        return sunrise;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
      default:
        return fajr;
    }
  }
}
