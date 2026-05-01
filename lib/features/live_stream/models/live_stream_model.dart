import 'package:thekr_app/core/services/remote_config_service.dart';

class LiveStream {
  final String id;
  final String title;
  final String youtubeId;
  final String? description;
  final String? thumbnailUrl;

  const LiveStream({
    required this.id,
    required this.title,
    required this.youtubeId,
    this.description,
    this.thumbnailUrl,
  });

  static List<LiveStream> get all => [
        LiveStream(
          id: 'madinah',
          title: 'بث المدينة المنورة - السنة النبوية',
          youtubeId: RemoteConfigService().madinahStreamId,
          description:
              'بث مباشر لقناة السنة النبوية من المسجد النبوي بالمدينة المنورة',
        ),
        LiveStream(
          id: 'makkah',
          title: 'بث مكة المكرمة - قرآن كريم',
          youtubeId: RemoteConfigService().makkahStreamId,
          description: 'بث مباشر من المسجد الحرام بمكة المكرمة',
        ),
      ];
}
