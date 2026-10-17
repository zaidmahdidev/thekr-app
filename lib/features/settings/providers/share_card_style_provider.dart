import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/services/cache_helper.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';

/// Share card style chosen by the user. Ratio and signature are remembered so
/// every image shared from the app (azkar, hadith, ...) uses the same look.
/// The font scale is a per-card tweak and is not persisted.
final shareCardStyleProvider =
    StateNotifierProvider<ShareCardStyleNotifier, ShareCardStyle>(
      (ref) => ShareCardStyleNotifier(),
    );

class ShareCardStyleNotifier extends StateNotifier<ShareCardStyle> {
  static const _ratioKey = 'shareCardRatio';
  static const _signatureKey = 'shareCardSignature';

  ShareCardStyleNotifier() : super(_load());

  static ShareCardStyle _load() {
    final ratioName = CacheHelper.getData(key: _ratioKey);
    final signature = CacheHelper.getData(key: _signatureKey);
    return ShareCardStyle(
      ratio: ShareCardRatio.values.firstWhere(
        (r) => r.name == ratioName,
        orElse: () => ShareCardRatio.portrait,
      ),
      showSignature: signature is bool ? signature : true,
    );
  }

  void setRatio(ShareCardRatio ratio) {
    state = state.copyWith(ratio: ratio);
    CacheHelper.saveData(key: _ratioKey, value: ratio.name);
  }

  void setShowSignature(bool value) {
    state = state.copyWith(showSignature: value);
    CacheHelper.saveData(key: _signatureKey, value: value);
  }

  void setFontScale(double value) {
    state = state.copyWith(fontScale: value);
  }
}
