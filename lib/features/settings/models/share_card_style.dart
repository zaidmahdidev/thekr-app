import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// Output shape of the shared card image.
enum ShareCardRatio {
  square,
  portrait,
  story;

  /// width / height
  double get aspect {
    switch (this) {
      case ShareCardRatio.square:
        return 1;
      case ShareCardRatio.portrait:
        return 4 / 5;
      case ShareCardRatio.story:
        return 9 / 16;
    }
  }

  String get label {
    switch (this) {
      case ShareCardRatio.square:
        return 'مربع';
      case ShareCardRatio.portrait:
        return 'عمودي';
      case ShareCardRatio.story:
        return 'ستوري';
    }
  }

  String get hint {
    switch (this) {
      case ShareCardRatio.square:
        return '1:1';
      case ShareCardRatio.portrait:
        return '4:5';
      case ShareCardRatio.story:
        return '9:16';
    }
  }

  AppIconData get icon {
    switch (this) {
      case ShareCardRatio.square:
        return HugeIcons.strokeRoundedSquare;
      case ShareCardRatio.portrait:
        return HugeIcons.strokeRoundedRectangular;
      case ShareCardRatio.story:
        return HugeIcons.strokeRoundedSmartPhone01;
    }
  }
}

/// Look-and-feel options of a share card, independent of the template.
class ShareCardStyle {
  final ShareCardRatio ratio;
  final double fontScale;
  final bool showSignature;

  const ShareCardStyle({
    this.ratio = ShareCardRatio.portrait,
    this.fontScale = 1.0,
    this.showSignature = true,
  });

  ShareCardStyle copyWith({
    ShareCardRatio? ratio,
    double? fontScale,
    bool? showSignature,
  }) {
    return ShareCardStyle(
      ratio: ratio ?? this.ratio,
      fontScale: fontScale ?? this.fontScale,
      showSignature: showSignature ?? this.showSignature,
    );
  }
}
