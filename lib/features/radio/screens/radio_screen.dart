import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_icon.dart';
import 'package:thekr_app/core/widgets/widgets.dart';
import '../providers/radio_controller.dart';
import '../providers/radio_providers.dart';
import '../widgets/radio_filter_bar.dart';
import '../widgets/radio_player_header.dart';
import '../widgets/radio_station_tile.dart';

/// Live Quran and Islamic radio stations. Audio stops when the screen closes.
///
/// The whole page scrolls: the player collapses into a slim pinned bar and the
/// category chips stay pinned under it.
@RoutePage()
class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      radioControllerProvider.select((radio) => radio.status),
    );
    final current = ref.watch(
      radioControllerProvider.select((radio) => radio.station?.id),
    );
    final isActive = ref.watch(
      radioControllerProvider.select((radio) => radio.isActive),
    );
    final controller = ref.read(radioControllerProvider.notifier);
    final stations = ref.watch(visibleRadioStationsProvider);
    final favorites = ref.watch(radioFavoritesProvider);
    final filter = ref.watch(radioFilterProvider);

    // The full player is taller while it explains an offline / error state.
    final expandedHeight = switch (status) {
      RadioStatus.error => 478.h,
      RadioStatus.offline => 432.h,
      _ => 376.h,
    };

    return AppScaffold(
      title: 'الإذاعة',
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: RadioPlayerHeaderDelegate(expandedHeight: expandedHeight),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: context.insets.md),
            sliver: const SliverToBoxAdapter(child: RadioSearchField()),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: RadioChipsHeaderDelegate(
              background: context.colors.background,
              child: const RadioFilterChips(),
            ),
          ),
          if (stations.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(favoritesOnly: filter == RadioFilter.favorites),
            )
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: context.insets.md),
              sliver: SliverList.builder(
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final isCurrent = current == station.id;
                  return RadioStationTile(
                    key: ValueKey(station.id),
                    station: station,
                    isCurrent: isCurrent,
                    isPlaying:
                        isCurrent && status == RadioStatus.playing,
                    isFavorite: favorites.contains(station.id),
                    onTap: () {
                      if (isCurrent && isActive) {
                        controller.pause();
                      } else {
                        controller.play(station);
                      }
                    },
                    onFavorite: () => ref
                        .read(radioFavoritesProvider.notifier)
                        .toggle(station.id),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    context.insets.lg + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.favoritesOnly});

  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              favoritesOnly
                  ? HugeIcons.strokeRoundedFavourite
                  : HugeIcons.strokeRoundedSearch01,
              size: 44.w,
              color: context.colors.textSecondary.withValues(alpha: 0.6),
            ),
            SizedBox(height: context.insets.md),
            Text(
              favoritesOnly ? 'لا توجد إذاعات في المفضلة' : 'لا توجد نتائج',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.insets.sm),
            Text(
              favoritesOnly
                  ? 'اضغط على القلب بجانب أي إذاعة لتجدها هنا.'
                  : 'جرّب كلمة بحث أخرى أو غيّر التصنيف.',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
