/// One saved preference, with the time it last changed on the device that
/// wrote it. The time decides which side wins when two devices disagree.
class SyncEntry {
  /// A JSON-safe value: String, int, double, bool or List<String>.
  final Object value;

  /// Milliseconds since epoch.
  final int at;

  const SyncEntry(this.value, this.at);

  /// Type tag so a whole number saved as a double is restored as a double.
  String get _tag {
    final v = value;
    if (v is String) return 's';
    if (v is bool) return 'b';
    if (v is int) return 'i';
    if (v is double) return 'd';
    return 'l';
  }

  Map<String, dynamic> toJson() => {'t': _tag, 'v': value, 'at': at};

  static SyncEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final v = raw['v'];
    final at = raw['at'];
    if (at is! num) return null;
    switch (raw['t']) {
      case 's':
        return v is String ? SyncEntry(v, at.toInt()) : null;
      case 'b':
        return v is bool ? SyncEntry(v, at.toInt()) : null;
      case 'i':
        return v is num ? SyncEntry(v.toInt(), at.toInt()) : null;
      case 'd':
        return v is num ? SyncEntry(v.toDouble(), at.toInt()) : null;
      case 'l':
        return v is List
            ? SyncEntry(v.map((e) => e.toString()).toList(), at.toInt())
            : null;
    }
    return null;
  }
}

/// A Quran bookmark in a form that does not depend on the Quran library.
class SyncBookmark {
  final int id;
  final int colorCode;
  final String name;
  final int ayahId;
  final int ayahNumber;
  final int page;

  const SyncBookmark({
    required this.id,
    required this.colorCode,
    required this.name,
    required this.ayahId,
    required this.ayahNumber,
    required this.page,
  });

  /// Identity across devices. The id alone is not enough: two devices can
  /// both hand out the same number to different bookmarks.
  String get key => '$id:$ayahId:$colorCode';

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': colorCode,
    'name': name,
    'ayahId': ayahId,
    'ayahNumber': ayahNumber,
    'page': page,
  };

  static SyncBookmark? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final color = raw['color'];
    if (id is! num || color is! num) return null;
    return SyncBookmark(
      id: id.toInt(),
      colorCode: color.toInt(),
      name: raw['name']?.toString() ?? '',
      ayahId: (raw['ayahId'] as num?)?.toInt() ?? -1,
      ayahNumber: (raw['ayahNumber'] as num?)?.toInt() ?? -1,
      page: (raw['page'] as num?)?.toInt() ?? -1,
    );
  }
}

/// The last known place of the user. Saved only when the app already has it;
/// nothing here is ever requested from the user.
class SyncLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? district;
  final int at;

  const SyncLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lng': longitude,
    if (city != null) 'city': city,
    if (district != null) 'district': district,
    'at': at,
  };

  static SyncLocation? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final lat = raw['lat'];
    final lng = raw['lng'];
    if (lat is! num || lng is! num) return null;
    return SyncLocation(
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      city: raw['city'] as String?,
      district: raw['district'] as String?,
      at: (raw['at'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Everything the account backs up, as one plain JSON-able document.
class SyncSnapshot {
  static const int currentVersion = 1;

  final int schemaVersion;
  final Map<String, SyncEntry> entries;
  final Map<String, SyncBookmark> bookmarks;

  /// Bookmark key -> when it was deleted, so a deletion is not undone by a
  /// device that still has the bookmark.
  final Map<String, int> deletedBookmarks;
  final SyncLocation? location;

  const SyncSnapshot({
    this.schemaVersion = currentVersion,
    this.entries = const {},
    this.bookmarks = const {},
    this.deletedBookmarks = const {},
    this.location,
  });

  bool get isEmpty =>
      entries.isEmpty &&
      bookmarks.isEmpty &&
      deletedBookmarks.isEmpty &&
      location == null;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'entries': {for (final e in entries.entries) e.key: e.value.toJson()},
    'bookmarks': [for (final b in bookmarks.values) b.toJson()],
    'deletedBookmarks': deletedBookmarks,
    if (location != null) 'location': location!.toJson(),
  };

  /// Tolerant on purpose: a malformed or newer entry is skipped instead of
  /// failing the whole restore.
  factory SyncSnapshot.fromJson(Map<String, dynamic> json) {
    final entries = <String, SyncEntry>{};
    final rawEntries = json['entries'];
    if (rawEntries is Map) {
      for (final e in rawEntries.entries) {
        final entry = SyncEntry.fromJson(e.value);
        if (entry != null) entries[e.key.toString()] = entry;
      }
    }

    final bookmarks = <String, SyncBookmark>{};
    final rawBookmarks = json['bookmarks'];
    if (rawBookmarks is List) {
      for (final raw in rawBookmarks) {
        final b = SyncBookmark.fromJson(raw);
        if (b != null) bookmarks[b.key] = b;
      }
    }

    final deleted = <String, int>{};
    final rawDeleted = json['deletedBookmarks'];
    if (rawDeleted is Map) {
      for (final e in rawDeleted.entries) {
        final at = e.value;
        if (at is num) deleted[e.key.toString()] = at.toInt();
      }
    }

    return SyncSnapshot(
      schemaVersion:
          (json['schemaVersion'] as num?)?.toInt() ?? SyncSnapshot.currentVersion,
      entries: entries,
      bookmarks: bookmarks,
      deletedBookmarks: deleted,
      location: SyncLocation.fromJson(json['location']),
    );
  }
}
