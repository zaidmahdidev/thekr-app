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

  static const List<LiveStream> defaults = [
    LiveStream(
      id: 'makkah',
      title: 'بث مكة المكرمة - قرآن كريم',
      youtubeId: 'fZvuHkHYaXk', // Stable live stream for Makkah
      description: 'بث مباشر من المسجد الحرام بمكة المكرمة',
    ),
    LiveStream(
      id: 'madinah',
      title: 'بث المدينة المنورة - السنة النبوية',
      youtubeId: 'vGGu3ZgGWXY', // Current stable Live ID
      description:
          'بث مباشر لقناة السنة النبوية من المسجد النبوي بالمدينة المنورة',
    ),
  ];
}
