// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AsmaAllahScreen]
class AsmaAllahRoute extends PageRouteInfo<void> {
  const AsmaAllahRoute({List<PageRouteInfo>? children})
    : super(AsmaAllahRoute.name, initialChildren: children);

  static const String name = 'AsmaAllahRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AsmaAllahScreen();
    },
  );
}

/// generated route for
/// [AthanSettingsScreen]
class AthanSettingsRoute extends PageRouteInfo<void> {
  const AthanSettingsRoute({List<PageRouteInfo>? children})
    : super(AthanSettingsRoute.name, initialChildren: children);

  static const String name = 'AthanSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AthanSettingsScreen();
    },
  );
}

/// generated route for
/// [AzkarListScreen]
class AzkarListRoute extends PageRouteInfo<AzkarListRouteArgs> {
  AzkarListRoute({
    Key? key,
    required List<Map<String, String>> azkarList,
    required String type,
    List<PageRouteInfo>? children,
  }) : super(
         AzkarListRoute.name,
         args: AzkarListRouteArgs(key: key, azkarList: azkarList, type: type),
         initialChildren: children,
       );

  static const String name = 'AzkarListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AzkarListRouteArgs>();
      return AzkarListScreen(
        key: args.key,
        azkarList: args.azkarList,
        type: args.type,
      );
    },
  );
}

class AzkarListRouteArgs {
  const AzkarListRouteArgs({
    this.key,
    required this.azkarList,
    required this.type,
  });

  final Key? key;

  final List<Map<String, String>> azkarList;

  final String type;

  @override
  String toString() {
    return 'AzkarListRouteArgs{key: $key, azkarList: $azkarList, type: $type}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AzkarListRouteArgs) return false;
    return key == other.key &&
        const ListEquality<Map<String, String>>().equals(
          azkarList,
          other.azkarList,
        ) &&
        type == other.type;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      const ListEquality<Map<String, String>>().hash(azkarList) ^
      type.hashCode;
}

/// generated route for
/// [AzkarScreen]
class AzkarRoute extends PageRouteInfo<void> {
  const AzkarRoute({List<PageRouteInfo>? children})
    : super(AzkarRoute.name, initialChildren: children);

  static const String name = 'AzkarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AzkarScreen();
    },
  );
}

/// generated route for
/// [CalendarScreen]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalendarScreen();
    },
  );
}

/// generated route for
/// [CustomizeHomeLayoutScreen]
class CustomizeHomeLayoutRoute extends PageRouteInfo<void> {
  const CustomizeHomeLayoutRoute({List<PageRouteInfo>? children})
    : super(CustomizeHomeLayoutRoute.name, initialChildren: children);

  static const String name = 'CustomizeHomeLayoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CustomizeHomeLayoutScreen();
    },
  );
}

/// generated route for
/// [CustomizeShareCardScreen]
class CustomizeShareCardRoute extends PageRouteInfo<void> {
  const CustomizeShareCardRoute({List<PageRouteInfo>? children})
    : super(CustomizeShareCardRoute.name, initialChildren: children);

  static const String name = 'CustomizeShareCardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CustomizeShareCardScreen();
    },
  );
}

/// generated route for
/// [HabitTrackerScreen]
class HabitTrackerRoute extends PageRouteInfo<void> {
  const HabitTrackerRoute({List<PageRouteInfo>? children})
    : super(HabitTrackerRoute.name, initialChildren: children);

  static const String name = 'HabitTrackerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HabitTrackerScreen();
    },
  );
}

/// generated route for
/// [HadithNawawiScreen]
class HadithNawawiRoute extends PageRouteInfo<void> {
  const HadithNawawiRoute({List<PageRouteInfo>? children})
    : super(HadithNawawiRoute.name, initialChildren: children);

  static const String name = 'HadithNawawiRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HadithNawawiScreen();
    },
  );
}

/// generated route for
/// [HajjChecklistScreen]
class HajjChecklistRoute extends PageRouteInfo<void> {
  const HajjChecklistRoute({List<PageRouteInfo>? children})
    : super(HajjChecklistRoute.name, initialChildren: children);

  static const String name = 'HajjChecklistRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjChecklistScreen();
    },
  );
}

/// generated route for
/// [HajjDayScreen]
class HajjDayRoute extends PageRouteInfo<HajjDayRouteArgs> {
  HajjDayRoute({
    Key? key,
    required int dayNumber,
    List<PageRouteInfo>? children,
  }) : super(
         HajjDayRoute.name,
         args: HajjDayRouteArgs(key: key, dayNumber: dayNumber),
         initialChildren: children,
       );

  static const String name = 'HajjDayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HajjDayRouteArgs>();
      return HajjDayScreen(key: args.key, dayNumber: args.dayNumber);
    },
  );
}

class HajjDayRouteArgs {
  const HajjDayRouteArgs({this.key, required this.dayNumber});

  final Key? key;

  final int dayNumber;

  @override
  String toString() {
    return 'HajjDayRouteArgs{key: $key, dayNumber: $dayNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HajjDayRouteArgs) return false;
    return key == other.key && dayNumber == other.dayNumber;
  }

  @override
  int get hashCode => key.hashCode ^ dayNumber.hashCode;
}

/// generated route for
/// [HajjIntroScreen]
class HajjIntroRoute extends PageRouteInfo<void> {
  const HajjIntroRoute({List<PageRouteInfo>? children})
    : super(HajjIntroRoute.name, initialChildren: children);

  static const String name = 'HajjIntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjIntroScreen();
    },
  );
}

/// generated route for
/// [HajjMistakesScreen]
class HajjMistakesRoute extends PageRouteInfo<void> {
  const HajjMistakesRoute({List<PageRouteInfo>? children})
    : super(HajjMistakesRoute.name, initialChildren: children);

  static const String name = 'HajjMistakesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjMistakesScreen();
    },
  );
}

/// generated route for
/// [HajjPermitScreen]
class HajjPermitRoute extends PageRouteInfo<void> {
  const HajjPermitRoute({List<PageRouteInfo>? children})
    : super(HajjPermitRoute.name, initialChildren: children);

  static const String name = 'HajjPermitRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjPermitScreen();
    },
  );
}

/// generated route for
/// [HajjScreen]
class HajjRoute extends PageRouteInfo<void> {
  const HajjRoute({List<PageRouteInfo>? children})
    : super(HajjRoute.name, initialChildren: children);

  static const String name = 'HajjRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjScreen();
    },
  );
}

/// generated route for
/// [HajjSpecialScreen]
class HajjSpecialRoute extends PageRouteInfo<void> {
  const HajjSpecialRoute({List<PageRouteInfo>? children})
    : super(HajjSpecialRoute.name, initialChildren: children);

  static const String name = 'HajjSpecialRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjSpecialScreen();
    },
  );
}

/// generated route for
/// [HajjTypesScreen]
class HajjTypesRoute extends PageRouteInfo<void> {
  const HajjTypesRoute({List<PageRouteInfo>? children})
    : super(HajjTypesRoute.name, initialChildren: children);

  static const String name = 'HajjTypesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HajjTypesScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [HusinAlMuslimDetailsScreen]
class HusinAlMuslimDetailsRoute
    extends PageRouteInfo<HusinAlMuslimDetailsRouteArgs> {
  HusinAlMuslimDetailsRoute({
    Key? key,
    required String title,
    required Map<String, dynamic> dhikrData,
    List<PageRouteInfo>? children,
  }) : super(
         HusinAlMuslimDetailsRoute.name,
         args: HusinAlMuslimDetailsRouteArgs(
           key: key,
           title: title,
           dhikrData: dhikrData,
         ),
         initialChildren: children,
       );

  static const String name = 'HusinAlMuslimDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HusinAlMuslimDetailsRouteArgs>();
      return HusinAlMuslimDetailsScreen(
        key: args.key,
        title: args.title,
        dhikrData: args.dhikrData,
      );
    },
  );
}

class HusinAlMuslimDetailsRouteArgs {
  const HusinAlMuslimDetailsRouteArgs({
    this.key,
    required this.title,
    required this.dhikrData,
  });

  final Key? key;

  final String title;

  final Map<String, dynamic> dhikrData;

  @override
  String toString() {
    return 'HusinAlMuslimDetailsRouteArgs{key: $key, title: $title, dhikrData: $dhikrData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HusinAlMuslimDetailsRouteArgs) return false;
    return key == other.key &&
        title == other.title &&
        const MapEquality<String, dynamic>().equals(dhikrData, other.dhikrData);
  }

  @override
  int get hashCode =>
      key.hashCode ^
      title.hashCode ^
      const MapEquality<String, dynamic>().hash(dhikrData);
}

/// generated route for
/// [HusinAlMuslimScreen]
class HusinAlMuslimRoute extends PageRouteInfo<void> {
  const HusinAlMuslimRoute({List<PageRouteInfo>? children})
    : super(HusinAlMuslimRoute.name, initialChildren: children);

  static const String name = 'HusinAlMuslimRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HusinAlMuslimScreen();
    },
  );
}

/// generated route for
/// [LiveStreamScreen]
class LiveStreamRoute extends PageRouteInfo<void> {
  const LiveStreamRoute({List<PageRouteInfo>? children})
    : super(LiveStreamRoute.name, initialChildren: children);

  static const String name = 'LiveStreamRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LiveStreamScreen();
    },
  );
}

/// generated route for
/// [MisbahaScreen]
class MisbahaRoute extends PageRouteInfo<void> {
  const MisbahaRoute({List<PageRouteInfo>? children})
    : super(MisbahaRoute.name, initialChildren: children);

  static const String name = 'MisbahaRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MisbahaScreen();
    },
  );
}

/// generated route for
/// [PrayerTimesScreen]
class PrayerTimesRoute extends PageRouteInfo<void> {
  const PrayerTimesRoute({List<PageRouteInfo>? children})
    : super(PrayerTimesRoute.name, initialChildren: children);

  static const String name = 'PrayerTimesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrayerTimesScreen();
    },
  );
}

/// generated route for
/// [ProphetDetailsScreen]
class ProphetDetailsRoute extends PageRouteInfo<ProphetDetailsRouteArgs> {
  ProphetDetailsRoute({
    Key? key,
    required ProphetStory prophet,
    List<PageRouteInfo>? children,
  }) : super(
         ProphetDetailsRoute.name,
         args: ProphetDetailsRouteArgs(key: key, prophet: prophet),
         initialChildren: children,
       );

  static const String name = 'ProphetDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProphetDetailsRouteArgs>();
      return ProphetDetailsScreen(key: args.key, prophet: args.prophet);
    },
  );
}

class ProphetDetailsRouteArgs {
  const ProphetDetailsRouteArgs({this.key, required this.prophet});

  final Key? key;

  final ProphetStory prophet;

  @override
  String toString() {
    return 'ProphetDetailsRouteArgs{key: $key, prophet: $prophet}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProphetDetailsRouteArgs) return false;
    return key == other.key && prophet == other.prophet;
  }

  @override
  int get hashCode => key.hashCode ^ prophet.hashCode;
}

/// generated route for
/// [ProphetsListScreen]
class ProphetsListRoute extends PageRouteInfo<void> {
  const ProphetsListRoute({List<PageRouteInfo>? children})
    : super(ProphetsListRoute.name, initialChildren: children);

  static const String name = 'ProphetsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProphetsListScreen();
    },
  );
}

/// generated route for
/// [QiblahScreen]
class QiblahRoute extends PageRouteInfo<void> {
  const QiblahRoute({List<PageRouteInfo>? children})
    : super(QiblahRoute.name, initialChildren: children);

  static const String name = 'QiblahRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QiblahScreen();
    },
  );
}

/// generated route for
/// [QuranScreen]
class QuranRoute extends PageRouteInfo<QuranRouteArgs> {
  QuranRoute({
    Key? key,
    required int currentPage,
    List<PageRouteInfo>? children,
  }) : super(
         QuranRoute.name,
         args: QuranRouteArgs(key: key, currentPage: currentPage),
         initialChildren: children,
       );

  static const String name = 'QuranRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuranRouteArgs>();
      return QuranScreen(key: args.key, currentPage: args.currentPage);
    },
  );
}

class QuranRouteArgs {
  const QuranRouteArgs({this.key, required this.currentPage});

  final Key? key;

  final int currentPage;

  @override
  String toString() {
    return 'QuranRouteArgs{key: $key, currentPage: $currentPage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuranRouteArgs) return false;
    return key == other.key && currentPage == other.currentPage;
  }

  @override
  int get hashCode => key.hashCode ^ currentPage.hashCode;
}

/// generated route for
/// [RadioScreen]
class RadioRoute extends PageRouteInfo<void> {
  const RadioRoute({List<PageRouteInfo>? children})
    : super(RadioRoute.name, initialChildren: children);

  static const String name = 'RadioRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RadioScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [UmrahChecklistScreen]
class UmrahChecklistRoute extends PageRouteInfo<void> {
  const UmrahChecklistRoute({List<PageRouteInfo>? children})
    : super(UmrahChecklistRoute.name, initialChildren: children);

  static const String name = 'UmrahChecklistRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahChecklistScreen();
    },
  );
}

/// generated route for
/// [UmrahIntroScreen]
class UmrahIntroRoute extends PageRouteInfo<void> {
  const UmrahIntroRoute({List<PageRouteInfo>? children})
    : super(UmrahIntroRoute.name, initialChildren: children);

  static const String name = 'UmrahIntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahIntroScreen();
    },
  );
}

/// generated route for
/// [UmrahMiqatScreen]
class UmrahMiqatRoute extends PageRouteInfo<void> {
  const UmrahMiqatRoute({List<PageRouteInfo>? children})
    : super(UmrahMiqatRoute.name, initialChildren: children);

  static const String name = 'UmrahMiqatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahMiqatScreen();
    },
  );
}

/// generated route for
/// [UmrahMistakesScreen]
class UmrahMistakesRoute extends PageRouteInfo<void> {
  const UmrahMistakesRoute({List<PageRouteInfo>? children})
    : super(UmrahMistakesRoute.name, initialChildren: children);

  static const String name = 'UmrahMistakesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahMistakesScreen();
    },
  );
}

/// generated route for
/// [UmrahProhibitionsScreen]
class UmrahProhibitionsRoute extends PageRouteInfo<void> {
  const UmrahProhibitionsRoute({List<PageRouteInfo>? children})
    : super(UmrahProhibitionsRoute.name, initialChildren: children);

  static const String name = 'UmrahProhibitionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahProhibitionsScreen();
    },
  );
}

/// generated route for
/// [UmrahScreen]
class UmrahRoute extends PageRouteInfo<void> {
  const UmrahRoute({List<PageRouteInfo>? children})
    : super(UmrahRoute.name, initialChildren: children);

  static const String name = 'UmrahRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UmrahScreen();
    },
  );
}

/// generated route for
/// [UmrahStepScreen]
class UmrahStepRoute extends PageRouteInfo<UmrahStepRouteArgs> {
  UmrahStepRoute({
    Key? key,
    required int stepNumber,
    List<PageRouteInfo>? children,
  }) : super(
         UmrahStepRoute.name,
         args: UmrahStepRouteArgs(key: key, stepNumber: stepNumber),
         initialChildren: children,
       );

  static const String name = 'UmrahStepRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UmrahStepRouteArgs>();
      return UmrahStepScreen(key: args.key, stepNumber: args.stepNumber);
    },
  );
}

class UmrahStepRouteArgs {
  const UmrahStepRouteArgs({this.key, required this.stepNumber});

  final Key? key;

  final int stepNumber;

  @override
  String toString() {
    return 'UmrahStepRouteArgs{key: $key, stepNumber: $stepNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UmrahStepRouteArgs) return false;
    return key == other.key && stepNumber == other.stepNumber;
  }

  @override
  int get hashCode => key.hashCode ^ stepNumber.hashCode;
}

/// generated route for
/// [UserAzkarScreen]
class UserAzkarRoute extends PageRouteInfo<void> {
  const UserAzkarRoute({List<PageRouteInfo>? children})
    : super(UserAzkarRoute.name, initialChildren: children);

  static const String name = 'UserAzkarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserAzkarScreen();
    },
  );
}
