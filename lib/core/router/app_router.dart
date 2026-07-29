import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:thekr_app/features/home/screens/home_screen.dart';
import 'package:thekr_app/features/azkar/screens/azkar_screen.dart';
import 'package:thekr_app/features/azkar/screens/azkar_details_screen.dart';
import 'package:thekr_app/features/husn_al_muslim/screens/husn_al_muslim_screen.dart';
import 'package:thekr_app/features/husn_al_muslim/screens/husn_al_muslim_details_screen.dart';
import 'package:thekr_app/features/asma_allah/screens/asma_allah_screen.dart';
import 'package:thekr_app/features/hadith/screens/hadith_nawawi.dart';
import 'package:thekr_app/features/prophets_stories/models/prophet_story.dart';
import 'package:thekr_app/features/qiblah/screens/qiblah_screen.dart';
import 'package:thekr_app/features/quran/screens/quran_screen.dart';
import 'package:thekr_app/features/settings/screens/settings_screen.dart';
import 'package:thekr_app/features/live_stream/screens/live_stream_screen.dart';
import 'package:thekr_app/features/prophets_stories/screens/prophets_list_screen.dart';
import 'package:thekr_app/features/prophets_stories/screens/prophet_details_screen.dart';
import 'package:thekr_app/features/misbaha/screens/misbaha_screen.dart';
import 'package:thekr_app/features/settings/screens/customize_share_card_screen.dart';
import 'package:thekr_app/features/settings/screens/customize_home_layout_screen.dart';
import 'package:thekr_app/features/azkar/screens/user_azkar_screen.dart';
import 'package:thekr_app/features/settings/screens/athan_settings_screen.dart';
import 'package:thekr_app/features/calendar/screens/calendar_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: AzkarRoute.page),
    AutoRoute(page: AzkarListRoute.page),
    AutoRoute(page: HusinAlMuslimRoute.page),
    AutoRoute(page: HusinAlMuslimDetailsRoute.page),
    AutoRoute(page: AsmaAllahRoute.page),
    AutoRoute(page: HadithNawawiRoute.page),
    AutoRoute(page: QiblahRoute.page),
    AutoRoute(page: QuranRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: LiveStreamRoute.page),
    AutoRoute(page: ProphetsListRoute.page),
    AutoRoute(page: ProphetDetailsRoute.page),
    AutoRoute(page: MisbahaRoute.page),
    AutoRoute(page: CustomizeHomeLayoutRoute.page),
    AutoRoute(page: CustomizeShareCardRoute.page),
    AutoRoute(page: UserAzkarRoute.page),
    AutoRoute(page: AthanSettingsRoute.page),
    AutoRoute(page: CalendarRoute.page),
  ];
}
