import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/services/share_service.dart';
import 'package:thekr_app/core/widgets/share_card_view.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/models/share_card_style.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';
import 'package:thekr_app/features/settings/providers/share_card_style_provider.dart';
import 'package:thekr_app/features/settings/widgets/share_studio/share_format_panel.dart';
import 'package:thekr_app/features/settings/widgets/share_studio/share_studio_tab_bar.dart';
import 'package:thekr_app/features/settings/widgets/share_studio/share_template_panel.dart';
import 'package:thekr_app/features/settings/widgets/share_studio/share_text_panel.dart';

/// Share card studio: live preview on top, editing panels at the bottom.
@RoutePage()
class CustomizeShareCardScreen extends ConsumerStatefulWidget {
  const CustomizeShareCardScreen({super.key});

  @override
  ConsumerState<CustomizeShareCardScreen> createState() =>
      _CustomizeShareCardScreenState();
}

class _CustomizeShareCardScreenState
    extends ConsumerState<CustomizeShareCardScreen> {
  static const _tabs = [
    ShareStudioTab(icon: Icons.edit_note_rounded, label: 'النص'),
    ShareStudioTab(icon: Icons.palette_rounded, label: 'القالب'),
    ShareStudioTab(icon: Icons.tune_rounded, label: 'التنسيق'),
  ];

  final TextEditingController _contentController = TextEditingController(
    text: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
  );
  final TextEditingController _sourceController = TextEditingController(
    text: 'سورة البقرة - آية 152',
  );

  int _tab = 0;
  bool _sharing = false;

  @override
  void dispose() {
    _contentController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  String get _content => _contentController.text.trim();
  String? get _source {
    final value = _sourceController.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _shareImage() async {
    if (_content.isEmpty) {
      showToast(text: 'يرجى كتابة نص أولاً', state: ToastStates.WARNING);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _sharing = true);
    await ShareService.shareAsImage(
      context,
      ref.read(settingsProvider).shareTemplate,
      _content,
      _source,
      isCustomText: true,
      style: ref.read(shareCardStyleProvider),
    );
    if (mounted) setState(() => _sharing = false);
  }

  void _shareText() {
    if (_content.isEmpty) {
      showToast(text: 'يرجى كتابة نص أولاً', state: ToastStates.WARNING);
      return;
    }
    ShareService.shareAsText(context, _content, _source, isCustomText: true);
  }

  Future<void> _copy() async {
    if (_content.isEmpty) return;
    final text = _source == null ? _content : '$_content\n\n$_source';
    await Clipboard.setData(ClipboardData(text: text));
    showToast(text: 'تم نسخ النص');
  }

  @override
  Widget build(BuildContext context) {
    final template = ref.watch(settingsProvider.select((s) => s.shareTemplate));
    final style = ref.watch(shareCardStyleProvider);

    return AppScaffold(
      title: 'بطاقة المشاركة',
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: _Preview(
                  contentController: _contentController,
                  sourceController: _sourceController,
                  template: template,
                  style: style,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.62,
                ),
                child: _BottomPanel(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShareStudioTabBar(
                          tabs: _tabs,
                          selected: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                        SizedBox(height: context.insets.md),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: KeyedSubtree(
                              key: ValueKey(_tab),
                              child: _buildPanel(template, style),
                            ),
                          ),
                        ),
                        SizedBox(height: context.insets.md),
                        _ActionRow(
                          sharing: _sharing,
                          onCopy: _copy,
                          onShareText: _shareText,
                          onShareImage: _shareImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel(ShareTemplate template, ShareCardStyle style) {
    switch (_tab) {
      case 0:
        return ShareTextPanel(
          contentController: _contentController,
          sourceController: _sourceController,
        );
      case 1:
        return ShareTemplatePanel(
          selected: template,
          onSelected: (t) =>
              ref.read(settingsProvider.notifier).updateShareTemplate(t),
        );
      default:
        final notifier = ref.read(shareCardStyleProvider.notifier);
        return ShareFormatPanel(
          style: style,
          onRatioChanged: notifier.setRatio,
          onFontScaleChanged: notifier.setFontScale,
          onSignatureChanged: notifier.setShowSignature,
        );
    }
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.contentController,
    required this.sourceController,
    required this.template,
    required this.style,
  });

  final TextEditingController contentController;
  final TextEditingController sourceController;
  final ShareTemplate template;
  final ShareCardStyle style;

  @override
  Widget build(BuildContext context) {
    final pixelHeight = (1080 / style.ratio.aspect).round();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.insets.lg,
        context.insets.md,
        context.insets.lg,
        context.insets.sm,
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  contentController,
                  sourceController,
                ]),
                builder: (context, _) {
                  final text = contentController.text.trim();
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: DecoratedBox(
                        key: ValueKey('${template.name}-${style.ratio.name}'),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 30,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ShareCardView(
                          template: template,
                          content: text.isEmpty ? 'اكتب نصك هنا...' : text,
                          subtitle: sourceController.text,
                          style: style,
                          isCustomText: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: context.insets.sm),
          Text(
            '${style.ratio.label} · 1080×$pixelHeight',
            style: context.textStyles.labelSmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.insets.md,
        context.insets.md,
        context.insets.md,
        context.insets.sm,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.corners.xl + 4.r),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.sharing,
    required this.onCopy,
    required this.onShareText,
    required this.onShareImage,
  });

  final bool sharing;
  final VoidCallback onCopy;
  final VoidCallback onShareText;
  final VoidCallback onShareImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SquareAction(
          icon: Icons.copy_rounded,
          tooltip: 'نسخ النص',
          onTap: onCopy,
        ),
        SizedBox(width: context.insets.sm),
        _SquareAction(
          icon: Icons.text_snippet_rounded,
          tooltip: 'مشاركة كنص',
          onTap: onShareText,
        ),
        SizedBox(width: context.insets.sm),
        Expanded(
          child: AppButton(
            text: 'مشاركة كصورة',
            icon: Icons.ios_share_rounded,
            isLoading: sharing,
            onTap: onShareImage,
          ),
        ),
      ],
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.corners.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(context.corners.md),
          onTap: onTap,
          child: SizedBox(
            width: 46.h,
            height: 46.h,
            child: Icon(icon, size: 20.sp, color: context.colors.primary),
          ),
        ),
      ),
    );
  }
}
