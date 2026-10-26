import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import '../models/radio_station.dart';
import 'radio_controller.dart';

/// Playback state. It lives as long as the app: leaving the radio screen, or
/// the app, does not stop the stream. The user stops it from the screen or from
/// the media notification.
final radioControllerProvider =
    StateNotifierProvider<RadioController, RadioState>(
      (ref) => RadioController(),
    );

class RadioFavoritesNotifier extends StateNotifier<Set<String>> {
  RadioFavoritesNotifier()
    : super(
        ((CacheHelper.getData(key: _key) as List<dynamic>?) ?? const [])
            .cast<String>()
            .toSet(),
      );

  static const String _key = 'radio_favorites';

  void toggle(String stationId) {
    final next = {...state};
    if (!next.add(stationId)) next.remove(stationId);
    state = next;
    CacheHelper.saveData(key: _key, value: next.toList());
  }
}

final radioFavoritesProvider =
    StateNotifierProvider<RadioFavoritesNotifier, Set<String>>(
      (ref) => RadioFavoritesNotifier(),
    );

/// What the station list is narrowed to.
enum RadioFilter {
  all('الكل'),
  favorites('المفضلة'),
  reciters('القراء'),
  mixed('تلاوات متنوعة'),
  adhkar('أذكار وسكينة'),
  knowledge('تفسير وعلوم'),
  translations('ترجمات المعاني');

  const RadioFilter(this.label);

  final String label;

  RadioCategory? get category => switch (this) {
    RadioFilter.reciters => RadioCategory.reciters,
    RadioFilter.mixed => RadioCategory.mixed,
    RadioFilter.adhkar => RadioCategory.adhkar,
    RadioFilter.knowledge => RadioCategory.knowledge,
    RadioFilter.translations => RadioCategory.translations,
    _ => null,
  };
}

final radioFilterProvider = StateProvider.autoDispose<RadioFilter>(
  (ref) => RadioFilter.all,
);

final radioSearchProvider = StateProvider.autoDispose<String>((ref) => '');

/// Stations after the filter chip and the search box are applied. This is also
/// the queue used by the next / previous buttons.
final visibleRadioStationsProvider =
    Provider.autoDispose<List<RadioStation>>((ref) {
      final filter = ref.watch(radioFilterProvider);
      final query = RadioStation.normalizeArabic(
        ref.watch(radioSearchProvider),
      );
      final favorites = ref.watch(radioFavoritesProvider);

      return RadioStation.available.where((station) {
        if (filter == RadioFilter.favorites &&
            !favorites.contains(station.id)) {
          return false;
        }
        final category = filter.category;
        if (category != null && station.category != category) return false;
        return query.isEmpty || station.searchKey.contains(query);
      }).toList();
    });
