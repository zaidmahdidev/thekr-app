import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:thekr_app/core/services/cache_helper.dart';

final featureBadgeProvider = StateNotifierProvider<FeatureBadgeNotifier, FeatureBadgeState>((ref) {
  return FeatureBadgeNotifier();
});

class FeatureBadgeState {
  final bool isInitialized;
  final String firstInstallVersion;
  final Map<String, int> featureClicks;

  FeatureBadgeState({
    this.isInitialized = false,
    this.firstInstallVersion = '',
    this.featureClicks = const {},
  });

  FeatureBadgeState copyWith({
    bool? isInitialized,
    String? firstInstallVersion,
    Map<String, int>? featureClicks,
  }) {
    return FeatureBadgeState(
      isInitialized: isInitialized ?? this.isInitialized,
      firstInstallVersion: firstInstallVersion ?? this.firstInstallVersion,
      featureClicks: featureClicks ?? this.featureClicks,
    );
  }
}

class FeatureBadgeNotifier extends StateNotifier<FeatureBadgeState> {
  static const int maxClicks = 3;
  static const String _installVersionKey = 'first_install_version';

  FeatureBadgeNotifier() : super(FeatureBadgeState()) {
    _init();
  }

  Future<void> _init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    String? savedVersion = CacheHelper.getData(key: _installVersionKey) as String?;

    if (savedVersion == null) {
      // Fresh install or first time tracking version
      savedVersion = currentVersion;
      await CacheHelper.saveData(key: _installVersionKey, value: savedVersion);
    }

    state = state.copyWith(
      isInitialized: true,
      firstInstallVersion: savedVersion,
    );
  }

  bool shouldShowBadge(String featureId, String addedInVersion) {
    if (!state.isInitialized) return false;

    // Check if the user installed the app AFTER or ON the version this feature was added.
    // If so, the feature is NOT "new" to them.
    if (_compareVersions(state.firstInstallVersion, addedInVersion) >= 0) {
      return false;
    }

    // Check click count
    final clicks = _getFeatureClicks(featureId);
    if (clicks >= maxClicks) {
      return false;
    }

    return true;
  }

  void recordFeatureClick(String featureId) {
    if (!state.isInitialized) return;

    final currentClicks = _getFeatureClicks(featureId);
    if (currentClicks < maxClicks) {
      final newClicks = currentClicks + 1;
      CacheHelper.saveData(key: 'clicks_$featureId', value: newClicks);
      
      final newMap = Map<String, int>.from(state.featureClicks);
      newMap[featureId] = newClicks;
      state = state.copyWith(featureClicks: newMap);
    }
  }

  int _getFeatureClicks(String featureId) {
    // Return from state if available, else from cache
    if (state.featureClicks.containsKey(featureId)) {
      return state.featureClicks[featureId]!;
    }
    final saved = CacheHelper.getData(key: 'clicks_$featureId');
    return saved is int ? saved : 0;
  }

  /// Returns > 0 if v1 > v2
  /// Returns < 0 if v1 < v2
  /// Returns 0 if v1 == v2
  int _compareVersions(String v1, String v2) {
    List<int> p1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> p2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int val1 = i < p1.length ? p1[i] : 0;
      int val2 = i < p2.length ? p2[i] : 0;
      if (val1 > val2) return 1;
      if (val1 < val2) return -1;
    }
    return 0;
  }
}
