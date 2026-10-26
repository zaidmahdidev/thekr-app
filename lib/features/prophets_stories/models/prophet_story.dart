/// Where a story's text comes from.
class StorySource {
  final String book;
  final String author;

  /// Edition / library, e.g. "المكتبة الشاملة - تحقيق ...".
  final String edition;

  /// How the text was used, shown to the reader.
  final String note;

  const StorySource({
    required this.book,
    required this.author,
    required this.edition,
    required this.note,
  });
}

class ProphetStory {
  final String id;
  final String name;
  final String title;
  final String brief;

  /// Legacy text of the story (not yet documented). For documented stories this
  /// is empty and [paragraphs] is used instead.
  final String fullStory;
  final List<String> lessons;
  final List<String> quranVerses;
  final String emoji;

  /// Documented text: paragraphs taken from [source]. Quranic passages inside a
  /// paragraph are wrapped in « » so the reader can highlight them.
  final List<String> paragraphs;
  final StorySource? source;

  /// The story told as one continuous narrative. Lines starting with '## ' are
  /// headings, Quranic verses are wrapped in « ». When present it is shown
  /// first and [paragraphs] becomes the collapsible detail from the source.
  final List<String> narrative;

  /// The references the [narrative] is built on.
  final String narrativeRefs;

  /// All the verses of the story, grouped by surah ('## ' lines are surah
  /// headings), shown apart from the [narrative] so the story stays fluid.
  final List<String> storyVerses;

  const ProphetStory({
    required this.id,
    required this.name,
    required this.title,
    required this.brief,
    required this.fullStory,
    required this.lessons,
    required this.quranVerses,
    required this.emoji,
    this.paragraphs = const [],
    this.source,
    this.narrative = const [],
    this.narrativeRefs = '',
    this.storyVerses = const [],
  });

  /// True when the story text comes from a named source.
  bool get isDocumented => source != null && paragraphs.isNotEmpty;

  /// Story as plain text (for copy and share).
  String get plainText => narrative.isNotEmpty
      ? narrative
            .map(_narrativeLineText)
            .join('\n\n')
            .replaceAll('«', '﴿')
            .replaceAll('»', '﴾')
      : isDocumented
      ? paragraphs.join('\n\n').replaceAll('«', '﴿').replaceAll('»', '﴾')
      : fullStory;

  static String _narrativeLineText(String line) {
    if (line.startsWith('## ')) return line.substring(3);
    if (line.startsWith('@@ ')) {
      final body = line.substring(3);
      final split = body.indexOf(' | ');
      if (split < 0) return body;
      return '﴿${body.substring(split + 3)}﴾ [${body.substring(0, split)}]';
    }
    return line;
  }

  /// Words of the story, for the reading time.
  int get wordCount =>
      plainText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  ProphetStory copyWith({
    String? title,
    String? brief,
    List<String>? lessons,
    List<String>? paragraphs,
    StorySource? source,
    List<String>? narrative,
    String? narrativeRefs,
    List<String>? storyVerses,
  }) {
    return ProphetStory(
      id: id,
      name: name,
      title: title ?? this.title,
      brief: brief ?? this.brief,
      fullStory: fullStory,
      lessons: lessons ?? this.lessons,
      quranVerses: quranVerses,
      emoji: emoji,
      paragraphs: paragraphs ?? this.paragraphs,
      source: source ?? this.source,
      narrative: narrative ?? this.narrative,
      narrativeRefs: narrativeRefs ?? this.narrativeRefs,
      storyVerses: storyVerses ?? this.storyVerses,
    );
  }

  factory ProphetStory.fromJson(Map<String, dynamic> json) {
    return ProphetStory(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      brief: json['brief'],
      fullStory: json['fullStory'] ?? '',
      lessons: List<String>.from(json['lessons'] ?? const []),
      quranVerses: List<String>.from(json['quranVerses'] ?? const []),
      emoji: json['emoji'] ?? '📜',
      paragraphs: List<String>.from(json['paragraphs'] ?? const []),
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
      'emoji': emoji,
      'paragraphs': paragraphs,
    };
  }
}
