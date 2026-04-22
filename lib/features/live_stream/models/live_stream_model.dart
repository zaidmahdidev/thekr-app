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
      youtubeId:
          'https://www.youtube.com/live/ZsD4toamOm4?si=HembJoJ2ir_1wt_E', // Stable Channel Embed ID
      description: 'بث مباشر لقناة القرآن الكريم من المسجد الحرام بمكة المكرمة',
    ),
    LiveStream(
      id: 'madinah',
      title: 'بث المدينة المنورة - السنة النبوية',
      youtubeId:
          'live_stream?channel=UCROKYPep-UuODNwyipe6JMw', // Stable Channel Embed ID
      description:
          'بث مباشر لقناة السنة النبوية من المسجد النبوي بالمدينة المنورة',
    ),
  ];
}
