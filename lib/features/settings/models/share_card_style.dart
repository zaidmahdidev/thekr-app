import 'package:flutter/material.dart';

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

  IconData get icon {
    switch (this) {
      case ShareCardRatio.square:
        return Icons.crop_square_rounded;
      case ShareCardRatio.portrait:
        return Icons.crop_portrait_rounded;
      case ShareCardRatio.story:
        return Icons.smartphone_rounded;
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
