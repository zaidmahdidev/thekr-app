class ProphetStory {
  final String id;
  final String name;
  final String title;
  final String brief;
  final String fullStory;
  final List<String> lessons;
  final List<String> quranVerses;
  final String? icon;

  const ProphetStory({
    required this.id,
    required this.name,
    required this.title,
    required this.brief,
    required this.fullStory,
    required this.lessons,
    required this.quranVerses,
    this.icon,
  });

  factory ProphetStory.fromJson(Map<String, dynamic> json) {
    return ProphetStory(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      brief: json['brief'],
      fullStory: json['fullStory'],
      lessons: List<String>.from(json['lessons']),
      quranVerses: List<String>.from(json['quranVerses']),
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'brief': brief,
      'fullStory': fullStory,
      'lessons': lessons,
      'quranVerses': quranVerses,
      'icon': icon,
    };
  }
}
