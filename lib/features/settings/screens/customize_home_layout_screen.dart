import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import 'package:thekr_app/features/settings/providers/settings_provider.dart';

@RoutePage()
class CustomizeHomeLayoutScreen extends ConsumerStatefulWidget {
  const CustomizeHomeLayoutScreen({super.key});

  @override
  ConsumerState<CustomizeHomeLayoutScreen> createState() =>
      _CustomizeHomeLayoutScreenState();
}

class _CustomizeHomeLayoutScreenState extends ConsumerState<CustomizeHomeLayoutScreen> {
  // قائمة محلية للاحتفاظ بالترتيب المؤقت قبل الحفظ
  late List<HomeSection> _tempSections;

  @override
  void initState() {
    super.initState();
    // الحصول على الترتيب الحالي عند فتح الشاشة
    final currentSections = ref.read(settingsProvider).homeSections;
    _tempSections = List.from(currentSections);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colors.background,
      title: 'ترتيب الشاشة الرئيسية',
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(context.insets.sm),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // حفظ الترتيب النهائي في البروفايدر والذاكرة
                  ref
                      .read(settingsProvider.notifier)
                      .reorderHomeSections(_tempSections);
                  context.router.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.insets.md),
                  elevation: 2,
                  shadowColor: context.colors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.corners.md),
                  ),
                ),
                child: const Text(
                  'حفظ الترتيب',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // إعادة الترتيب الافتراضي محلياً فقط
                  setState(() {
                    _tempSections = List.from(HomeSection.values);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.insets.md),
                  side: BorderSide(color: context.colors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.corners.md),
                  ),
                ),
                child: Text(
                  'الافتراضي',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ReorderableListView(
        padding: EdgeInsets.all(context.insets.md),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final section = _tempSections.removeAt(oldIndex);
            _tempSections.insert(newIndex, section);
          });
        },
        children: [
          for (final section in _tempSections)
            Padding(
              key: ValueKey(section),
              padding: EdgeInsets.only(bottom: context.insets.md),
              child: _SectionPreviewCard(section: section),
            ),
        ],
      ),
    );
  }
}

class _SectionPreviewCard extends StatelessWidget {
  final HomeSection section;

  const _SectionPreviewCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(context.corners.lg),
        boxShadow: context.shadows.low,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.corners.lg),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.insets.md,
                vertical: context.insets.sm,
              ),
              color: context.colors.primary.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator_rounded,
                    color: context.colors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section.title,
                    style: context.textStyles.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(context.insets.md),
              child: _buildPreviewContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    switch (section) {
      case HomeSection.prayerTimes:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            5,
            (index) => Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time,
                    size: 14,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: 25, height: 4, color: Colors.grey.shade300),
              ],
            ),
          ),
        );
      case HomeSection.inspiration:
        return Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(context.corners.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: context.colors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Container(width: 40, height: 4, color: Colors.grey.shade400),
                ],
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 150,
                  height: 6,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  width: 100,
                  height: 6,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        );
      case HomeSection.features:
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            4,
            (index) => Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(context.corners.sm),
              ),
              child: Icon(
                Icons.apps,
                size: 16,
                color: context.colors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        );
      case HomeSection.dynamicSections:
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(Icons.event, color: Colors.amber, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.corners.sm),
                  border: Border.all(
                    color: context.colors.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: context.colors.secondary,
                  size: 16,
                ),
              ),
            ),
          ],
        );
      case HomeSection.shareCard:
        return Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary,
                context.colors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(context.corners.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 6,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        );
    }
  }
}
