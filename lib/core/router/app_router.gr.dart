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
/// [NotificationSettingsScreen]
class NotificationSettingsRoute extends PageRouteInfo<void> {
  const NotificationSettingsRoute({List<PageRouteInfo>? children})
    : super(NotificationSettingsRoute.name, initialChildren: children);

  static const String name = 'NotificationSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationSettingsScreen();
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
/// [SurahScreen]
class SurahRoute extends PageRouteInfo<SurahRouteArgs> {
  SurahRoute({
    Key? key,
    required int currentPage,
    List<PageRouteInfo>? children,
  }) : super(
         SurahRoute.name,
         args: SurahRouteArgs(key: key, currentPage: currentPage),
         initialChildren: children,
       );

  static const String name = 'SurahRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SurahRouteArgs>();
      return SurahScreen(key: args.key, currentPage: args.currentPage);
    },
  );
}

class SurahRouteArgs {
  const SurahRouteArgs({this.key, required this.currentPage});

  final Key? key;

  final int currentPage;

  @override
  String toString() {
    return 'SurahRouteArgs{key: $key, currentPage: $currentPage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SurahRouteArgs) return false;
    return key == other.key && currentPage == other.currentPage;
  }

  @override
  int get hashCode => key.hashCode ^ currentPage.hashCode;
}
