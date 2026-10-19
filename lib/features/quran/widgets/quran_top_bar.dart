import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/features/quran/models/quran_reader_palette.dart';
import 'package:thekr_app/features/quran/providers/quran_provider.dart';
import 'package:thekr_app/features/quran/services/quran_reader_adapter.dart';
import 'package:thekr_app/features/quran/widgets/navigator/quran_navigator_sheet.dart';
import 'package:thekr_app/features/quran/widgets/quran_more_menu.dart';
import 'package:thekr_app/features/quran/widgets/quran_page_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';

/// App-styled top bar for the Quran reader, colored by the reading theme.
///
/// Replaces the library's default bar so the most used actions (index, search,
/// tasmee) are one tap away, while the rest live in the "more" sheet. It follows
/// the library's show/hide behaviour (tap on the page toggles the controls).
class QuranTopBar extends ConsumerStatefulWidget {
  const QuranTopBar({
    super.key,
    required this.providerPage,
    required this.palette,
    required this.themesOpen,
    required this.onBack,
    required this.onToggleThemes,
    required this.onSharePage,
  });

  final int providerPage;
  final QuranReaderPalette palette;
  final bool themesOpen;
  final VoidCallback onBack;
  final VoidCallback onToggleThemes;
  final VoidCallback onSharePage;

  @override
  ConsumerState<QuranTopBar> createState() => _QuranTopBarState();
}

class _QuranTopBarState extends ConsumerState<QuranTopBar> {
  final List<StreamSubscription<bool>> _subs = [];

  bool _controlsVisible = true;
  bool _autoScrolling = false;
  bool _tasmeeActive = false;

  @override
  void initState() {
    super.initState();
    _controlsVisible = QuranReaderAdapter.controlsVisible;
    _autoScrolling = QuranReaderAdapter.isAutoScrolling;
    _tasmeeActive = QuranReaderAdapter.isTasmeeActive;

    final controls = QuranReaderAdapter.listenControlsVisible(
      (v) => _update(() => _controlsVisible = v),
    );
    final tasmee = QuranReaderAdapter.listenTasmee(
      (v) => _update(() => _tasmeeActive = v),
    );
    _subs
      ..addAll(
        QuranReaderAdapter.listenAutoScrolling(
          (running) => _update(() => _autoScrolling = running),
        ),
      )
      ..addAll([?controls, ?tasmee]);
  }

  void _update(VoidCallback change) {
    if (mounted) setState(change);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  int get _currentPage =>
      ref.read(quranProvider(widget.providerPage)).currentPage;

  void _openNavigator(QuranNavigatorTab tab) {
    showQuranNavigator(
      context,
      initialTab: tab,
      currentPage: _currentPage,
      palette: widget.palette,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final visible = _controlsVisible && !_autoScrolling;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.corners.lg),
                boxShadow: context.shadows.medium,
              ),
              // The reader has no Scaffold, so the bar provides its own Material
              // (needed by IconButton / ink splashes).
              child: Material(
                color: palette.surface,
                borderRadius: BorderRadius.circular(context.corners.lg),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Row(
                        children: [
                          _BarIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            tooltip: 'رجوع',
                            color: palette.text,
                            size: 18.sp,
                            onTap: widget.onBack,
                          ),
                          _BarIcon(
                            icon: HugeIcons.strokeRoundedList,
                            tooltip: 'الفهرس',
                            color: palette.icon,
                            onTap: () =>
                                _openNavigator(QuranNavigatorTab.contents),
                          ),
                          _BarIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            tooltip: 'بحث',
                            color: palette.icon,
                            onTap: () =>
                                _openNavigator(QuranNavigatorTab.search),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                context.corners.md,
                              ),
                              onTap: () =>
                                  _openNavigator(QuranNavigatorTab.contents),
                              child: Center(
                                child: QuranPageIndicator(
                                  providerPage: widget.providerPage,
                                  palette: palette,
                                ),
                              ),
                            ),
                          ),
                          _BarIcon(
                            icon: HugeIcons.strokeRoundedMic01,
                            tooltip: 'التسميع',
                            color: palette.icon,
                            activeColor: palette.accent,
                            active: _tasmeeActive,
                            onTap: QuranReaderAdapter.toggleTasmee,
                          ),
                          _BarIcon(
                            icon: HugeIcons.strokeRoundedPalette,
                            tooltip: 'نمط القراءة',
                            color: palette.icon,
                            activeColor: palette.accent,
                            active: widget.themesOpen,
                            onTap: widget.onToggleThemes,
                          ),
                          QuranMoreMenuButton(
                            palette: palette,
                            onSharePage: widget.onSharePage,
                          ),
                        ],
                      ),
                    ),
                    // Thin reading-progress line along the bottom edge.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ReadingProgress(
                        providerPage: widget.providerPage,
                        color: palette.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadingProgress extends ConsumerWidget {
  const _ReadingProgress({required this.providerPage, required this.color});

  final int providerPage;
  final Color color;

  static const int _totalPages = 604;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(
      quranProvider(providerPage).select((s) => s.currentPage),
    );
    return LinearProgressIndicator(
      value: (page / _totalPages).clamp(0.0, 1.0),
      minHeight: 2.5,
      backgroundColor: Colors.transparent,
      color: color,
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.color,
    this.activeColor,
    this.active = false,
    this.size,
  });

  final AppIconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  final Color? activeColor;
  final bool active;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final tint = active ? (activeColor ?? color) : color;

    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 38.w, height: 44.h),
      style: IconButton.styleFrom(
        backgroundColor: active
            ? tint.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      icon: AppIcon(icon, size: size ?? 22.sp, color: tint),
    );
  }
}
