import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_bottom_sheet.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../data/umrah_miqat_data.dart';
import '../models/umrah_models.dart';
import '../providers/umrah_text.dart';
import '../widgets/miqat_answer_card.dart';
import '../widgets/miqat_diagram.dart';
import '../widgets/miqat_origin_tile.dart';
import '../widgets/umrah_disclaimer.dart';
import '../widgets/umrah_font_actions.dart';
import '../widgets/umrah_section_title.dart';
import '../widgets/umrah_segmented_control.dart';

/// Tells the pilgrim where to put on ihram. Pick how you are arriving, then
/// either tap a miqat on the schematic or choose where you come from; the
/// answer opens right away in a sheet.
@RoutePage()
class UmrahMiqatScreen extends ConsumerStatefulWidget {
  const UmrahMiqatScreen({super.key});

  @override
  ConsumerState<UmrahMiqatScreen> createState() => _UmrahMiqatScreenState();
}

class _UmrahMiqatScreenState extends ConsumerState<UmrahMiqatScreen> {
  MiqatGroup _group = MiqatGroup.land;
  MiqatOrigin? _selected;

  List<MiqatOrigin> get _origins =>
      UmrahMiqatData.origins.where((o) => o.group == _group).toList();

  void _select(MiqatOrigin origin) {
    setState(() => _selected = origin);
    _showAnswer(origin);
  }

  void _selectSpot(MiqatSpot spot) {
    final origin = UmrahMiqatData.origins.firstWhere((o) => o.spotId == spot.id);
    _select(origin);
  }

  Future<void> _showAnswer(MiqatOrigin origin) {
    return AppBottomSheet.show<void>(
      context: context,
      title: origin.label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: MiqatAnswerCard(answer: origin.answer, framed: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(umrahTextProvider);
    final origins = _origins;
    final selectedSpotId = _selected?.group == MiqatGroup.land
        ? _selected?.spotId
        : null;

    return AppScaffold(
      appBar: BaseAppBar(title: 'من أين أحرم؟', actions: umrahFontActions(ref)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.insets.md,
          context.insets.sm,
          context.insets.md,
          context.insets.lg + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            'لكل جهة ميقات حدّده النبي ﷺ. كيف ستصل إلى مكة؟',
            style: text.body(context, color: context.colors.textSecondary),
          ),
          SizedBox(height: context.insets.md),
          UmrahSegmentedControl<MiqatGroup>(
            values: MiqatGroup.values,
            selected: _group,
            labelOf: (group) => group.label,
            onChanged: (group) => setState(() {
              _group = group;
              _selected = null;
            }),
          ),
          SizedBox(height: context.insets.lg),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(_group),
              child: _group == MiqatGroup.land
                  ? _LandSection(
                      origins: origins,
                      selected: _selected,
                      selectedSpotId: selectedSpotId,
                      onSelectSpot: _selectSpot,
                      onSelectOrigin: _select,
                    )
                  : _SimpleSection(
                      group: _group,
                      origins: origins,
                      selected: _selected,
                      onSelect: _select,
                    ),
            ),
          ),
          SizedBox(height: context.insets.lg),
          const _GeneralEvidence(),
          SizedBox(height: context.insets.md),
          const UmrahDisclaimer(text: UmrahMiqatData.locationsNote),
          SizedBox(height: context.insets.sm),
          const UmrahDisclaimer(),
        ],
      ),
    );
  }
}

/// Schematic plus the list of places people come from.
class _LandSection extends StatelessWidget {
  const _LandSection({
    required this.origins,
    required this.selected,
    required this.selectedSpotId,
    required this.onSelectSpot,
    required this.onSelectOrigin,
  });

  final List<MiqatOrigin> origins;
  final MiqatOrigin? selected;
  final String? selectedSpotId;
  final ValueChanged<MiqatSpot> onSelectSpot;
  final ValueChanged<MiqatOrigin> onSelectOrigin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const UmrahSectionTitle('المواقيت الخمسة'),
        SizedBox(height: context.insets.sm),
        MiqatDiagram(selectedId: selectedSpotId, onSelect: onSelectSpot),
        Center(
          child: Text(
            'مخطط توضيحي للاتجاهات وليس بمقياس رسم. اضغط على ميقات لتفاصيله.',
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(height: context.insets.lg),
        const UmrahSectionTitle('أو اختر من أين أنت قادم'),
        SizedBox(height: context.insets.md),
        for (final origin in origins)
          MiqatOriginTile(
            origin: origin,
            selected: identical(origin, selected),
            onTap: () => onSelectOrigin(origin),
          ),
      ],
    );
  }
}

/// Groups with only a few cases: the tiles alone, or the answer itself when
/// there is just one.
class _SimpleSection extends StatelessWidget {
  const _SimpleSection({
    required this.group,
    required this.origins,
    required this.selected,
    required this.onSelect,
  });

  final MiqatGroup group;
  final List<MiqatOrigin> origins;
  final MiqatOrigin? selected;
  final ValueChanged<MiqatOrigin> onSelect;

  @override
  Widget build(BuildContext context) {
    if (origins.length == 1) {
      return MiqatAnswerCard(answer: origins.first.answer);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UmrahSectionTitle(group == MiqatGroup.resident ? 'أين تقيم؟' : group.label),
        SizedBox(height: context.insets.md),
        for (final origin in origins)
          MiqatOriginTile(
            origin: origin,
            selected: identical(origin, selected),
            onTap: () => onSelect(origin),
          ),
      ],
    );
  }
}

class _GeneralEvidence extends ConsumerWidget {
  const _GeneralEvidence();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(umrahTextProvider);
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.12)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: context.insets.md),
          childrenPadding: EdgeInsets.fromLTRB(
            context.insets.md,
            0,
            context.insets.md,
            context.insets.md,
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text('الأصل في المواقيت', style: text.title(context)),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              UmrahMiqatData.generalEvidence,
              style: text.body(context, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
